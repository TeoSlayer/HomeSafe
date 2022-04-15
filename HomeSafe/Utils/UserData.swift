//
//  UserData.swift
//  HomeSafe
//
//  Created by Calin Teodor on 21.02.2022.
//

import Foundation
import Combine
import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import OneSignal

class UserData: ObservableObject{
    static let Shared = UserData()
    let settings = FirestoreSettings()
    let db = Firestore.firestore()
    init(){}
    
    @Published var LoggedIn : Bool = Auth.auth().currentUser?.uid != nil ? true : false
    @Published var LocalUser : User?
    @Published var PartnerStatus : Bool = false
    @Published var PartnerOnesignal : String = ""
    
    func RetrieveUser(UserId: String){
        db.settings.isPersistenceEnabled = true
        let userdbref = db.collection("Users").document(UserId)
        var listner = userdbref.addSnapshotListener{ [self] (snapshot, err) in
            if var data = snapshot?.data() {
                let dbuser = User(Id: data["Id"] as? String ?? "", PersonalCode: data["PersonalCode"] as? String ?? "",PartnerCode: data["PartnerCode"] as? String ?? "", Email: data["Email"] as? String ?? "", PersonalStatus: data["PersonalStatus"] as? Bool ?? true)
                self.LocalUser = dbuser
                SharedUserData.Shared.LocalUser = dbuser
                
                if(LocalUser?.PartnerCode != ""){
                    self.getPartnerStatus(Id: LocalUser!.PartnerCode)
                }
                self.LoggedIn = true
            } else {
                print("Couldn't find the document")
            }
        }
    }
    
    func PushUser(Id: String, Email: String){
        let playerid = OneSignal.getDeviceState().userId
        let personalCode = generateRandomNonceString()
        let userdbref = db.collection("Users").document(Id).setData(["Id": Id,
                                                                     "Email": Email,
                                                                     "PersonalCode": personalCode,
                                                                     "PartnerCode": "",
                                                                     "PersonalStatus": true,
                                                                     "Onesignal": playerid
                                                            
        ]){err in
            if let err = err{
                print("Error while creating account. Check your internet connection and try again")
            }else{
                self.RetrieveUser(UserId: Id)
            }
        }
    }
    
    func checkIfUserExists(Id: String,completion: @escaping (Bool) -> ()){
        print("Checking if user exists in DB")
        let userdbref = db.collection("Users").document(Id)
        userdbref.getDocument(completion: {(document, err) in
            if let document = document, document.exists{
                self.RetrieveUser(UserId: Id)
                completion(true)
            }
            else{
                print("User does not exist")
                completion(false)
            }
        })
    }
    
    func getPartnerStatus(Id: String){
        db.settings.isPersistenceEnabled = true
        let userdbref = db.collection("Users").document(Id)
        var listner = userdbref.addSnapshotListener{ [self] (snapshot, err) in
            if var data = snapshot?.data() {
                let dbuser = User(Id: data["Id"] as? String ?? "", PersonalCode: data["PersonalCode"] as? String ?? "",PartnerCode: data["PartnerCode"] as? String ?? "", Email: data["Email"] as? String ?? "", PersonalStatus: data["PersonalStatus"] as? Bool ?? true)
                self.PartnerStatus = dbuser.PersonalStatus
                self.PartnerOnesignal = data["Onesignal"] as? String ?? ""
                SharedUserData.Shared.PartnerStatus = self.PartnerStatus
            } else {
                print("Couldn't find the document")
            }
        }
    }
    
    func matchPartner(PartnerCode: String){
        print("Matching with Partner with code \(PartnerCode)")
        let userdbref = db.collection("Users").whereField("PersonalCode", isEqualTo: PartnerCode).getDocuments(completion: { [self] (querySnapshot, err) in
            if let err = err{
                    print("failed to retrieve partner")
                    //to add alert
            }
            else{
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                }
                print("Received Query")
                print(querySnapshot?.documents.count)
                if(querySnapshot?.documents.count ?? 0 > 0){
                let doc = querySnapshot!.documents.first
                print(doc)
                let partnerId = doc!.documentID
                print(partnerId)
                let userDocRef = self.db.collection("Users").document(partnerId).updateData([ "PartnerCode": self.LocalUser?.Id]){err in
                    if let err = err{
                        print("Error while matching partner")
                    }else{
                        self.LocalUser?.PartnerCode = doc!.data()["Id"] as! String
                        let selfuserdbref = db.collection("Users").document(self.LocalUser!.Id).updateData([ "PartnerCode": partnerId ]){err in
                            if let err = err{
                                print("Error while creating account. Check your internet connection and try again")
                            }else{
                                self.getOnesignalForID(Id: partnerId, completion: {(onesignalID) in
                                    self.PartnerOnesignal = onesignalID
                                    OneSignal.postNotification(["contents": ["en": "Hey! Your partner just matched with you!!"], "include_player_ids": ["\(onesignalID)"]])
                                    self.RetrieveUser(UserId: Auth.auth().currentUser!.uid)
                                })
                                
                            }
                        }
                    }
                }
                }
                }
        })
    }
    
    func unMatchPartner(PartnerCode: String){
        let userdbref = db.collection("Users").document(PartnerCode).updateData([ "PartnerCode": self.LocalUser?.PersonalCode ]){err in
            if let err = err{
                print("Error while matching partner")
            }else{
                let selfuserdbref = self.db.collection("Users").document(self.LocalUser!.Id ?? "").updateData([ "PartnerCode": "" ]){err in
                    if let err = err{
                        print("Error while creating account. Check your internet connection and try again")
                    }else{
                        self.RetrieveUser(UserId: Auth.auth().currentUser!.uid)
                    }
                }
            }
        }
    }
    
    
    func pushPersonalStatus(Id: String, NewPersonalStatus: Bool){
        let playerid = OneSignal.getDeviceState().userId
        let userdbref = db.collection("Users").document(Id).updateData([ "PersonalStatus": NewPersonalStatus, "Onesignal": playerid]){err in
            if let err = err{
                print("Error while creating account. Check your internet connection and try again")
            }else{
                self.LocalUser?.PersonalStatus = NewPersonalStatus
                SharedUserData.Shared.LocalUser.PersonalStatus = NewPersonalStatus
                OneSignal.postNotification(["contents": ["en": "Hey! Your partner is \(NewPersonalStatus == false ? "now Home Safe" : "no longer Home Safe" )"], "include_player_ids": ["\(self.PartnerOnesignal)"]])
            }
        }
    }
    
    func getOnesignalForID(Id: String, completion: @escaping (String) -> ()){
        let userdbref = db.collection("Users").document(Id)
        userdbref.getDocument(completion: {(snapshot, err) in
            if var data = snapshot?.data() {
                let onesignal = data["Onesignal"] as? String ?? ""
                completion(onesignal)
            } else {
                print("Couldn't find the document")
                completion("Err")
            }
        })
    }
    
    private func EmptyUser() -> User {
        let user = User(Id: "", PersonalCode: "", PartnerCode: "", Email: "", PersonalStatus: true)
        return user
    }
    
    private func generateRandomNonceString(length: Int = 6) -> String {
     precondition(length > 0)
     let charset: Array<Character> =
         Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz")
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
    
    func signOut(){
        do { try Auth.auth().signOut()}
        catch { print("already logged out") }
        self.LoggedIn = false
        self.purgeData()
    }
    
    func purgeData(){
        self.LocalUser = EmptyUser()
        self.PartnerStatus = false
        self.PartnerOnesignal = ""
        
        SharedUserData.Shared.PartnerStatus = false
        SharedUserData.Shared.LocalUser = EmptyUser()
    }
    
}
