//
//  Login.swift
//  HomeSafe
//
//  Created by Calin Teodor on 22.02.2022.
//


import SwiftUI
import AuthenticationServices
import CryptoKit
import FirebaseAuth
import UIKit

fileprivate var currentNonce: String?



struct Login: View {
    var body: some View {
        ZStack{
            Color(accentPurple).ignoresSafeArea(.all)
            VStack(alignment: .leading){
                Image("TransparentLogoFull").resizable().frame(width: 185, height: 185, alignment: .center).padding(.top,144).padding(.leading, 53)
                Text("HomeSafe").foregroundColor(Color(accentGrey))
                    .font(.title).padding(.leading, 59)
                Text("Know when your partner is home safe.").foregroundColor(Color(accentGreen))
                    .font(.body).padding(.leading, 59)
                Spacer()
                QuickSignInWithApple().foregroundColor(.white).cornerRadius(15).frame(height: 50).padding(.horizontal,59).padding(.bottom)
            }.frame(maxHeight: .infinity)
        }.background(Color(accentPurple))
    }
}

struct Login_Previews: PreviewProvider {
    static var previews: some View {
        Login()
    }
}

struct QuickSignInWithApple: UIViewRepresentable {
    func makeCoordinator() -> AppleSignUpCoordinator {
        return AppleSignUpCoordinator(self)
    }
    
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {

        let button = ASAuthorizationAppleIDButton(authorizationButtonType: .continue,
                                                  authorizationButtonStyle: .white)
        button.cornerRadius = 15
        
        
        button.addTarget(context.coordinator,
                         action: #selector(AppleSignUpCoordinator.didTapButton),
                         for: .touchUpInside)
            
        return button
    }
    
    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {
    }
}

func randomNonceString(length: Int = 32) -> String {
 precondition(length > 0)
 let charset: Array<Character> =
     Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
 var result = ""
 var remainingLength = length

 while remainingLength > 0 {
   let randoms: [UInt8] = (0 ..< 16).map { _ in
     var random: UInt8 = 0
     let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
     if errorCode != errSecSuccess {
       fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
     }
     return random
   }

   randoms.forEach { random in
     if remainingLength == 0 {
       return
     }

     if random < charset.count {
       result.append(charset[Int(random)])
       remainingLength -= 1
     }
   }
 }

 return result
}


class AppleSignUpCoordinator: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    var parent: QuickSignInWithApple?
    
    init(_ parent: QuickSignInWithApple) {
        self.parent = parent
        super.init()

    }
    
    @objc func didTapButton() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func sha256(_ input: String) -> String {
     let inputData = Data(input.utf8)
     let hashedData = SHA256.hash(data: inputData)
     let hashString = hashedData.compactMap {
       return String(format: "%02x", $0)
     }.joined()

     return hashString
    }

    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        let vc = UIApplication.shared.windows.last?.rootViewController
        return (vc?.view.window!)!
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            
    
              guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
              }
              guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
              }
              guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
              }
              // Initialize a Firebase credential.
              let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                        idToken: idTokenString,
                                                        rawNonce: nonce)
              // Sign in with Firebase.
                Auth.auth().signIn(with: credential) { (authResult, error) in
                    if (error != nil) {
                      print(error?.localizedDescription)
                      return
                    }
                    print("Apple login")
                    UserData.Shared.checkIfUserExists(Id: Auth.auth().currentUser?.uid ?? "", completion: ({result in
                    if result == false{
                        print("User does not exist, continuing to onboarding...")
                        UserData.Shared.PushUser(Id: Auth.auth().currentUser?.uid ?? "", Email: Auth.auth().currentUser?.email ?? "")
                    }
                    else{
                        print("Fetching user info, logging in...")
                        UserData.Shared.RetrieveUser(UserId: (Auth.auth().currentUser?.uid)!)
                        
                    }
                }))
              }
            }

    }

    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        //Set this to true even if it threw an error in order to be able to work on the app anyways
        
        print("Sign in with Apple errored: \(error)")
    }
}
