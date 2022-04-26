//
//  Home.swift
//  HomeSafeUI
//
//  Created by Calin Teodor on 22.02.2022.
//

import SwiftUI
import FirebaseAuth

struct Home: View {
    @State var code = ""
    @State var removeAlertShown = false
    @State var addedAlertShown = false
    @State var devActive = false
    @EnvironmentObject var userData : UserData
    var body: some View {
        VStack(spacing: 0){
             VStack(alignment: .leading){
                HStack{
                    Spacer()
                    
                    NavigationLink(destination: Dev(isActive: $devActive), isActive: $devActive, label: {Rectangle().frame(width: 0, height: 0)})
                    
                    Button(action: {
                        devActive = true
                    }) {
                        TopButton(text: "Dev", strokeColor: Color(accentGreen), backgroundColor: Color(accentRed), textColor: Color(accentGreen))
                    }
                    Button(action: {
                        userData.signOut()
                    }) {
                        TopButton(text: "Log Off", strokeColor: Color(accentGreen), backgroundColor: Color(accentRed), textColor: Color(accentGreen))
                    }
                }.padding([.top],UIScreen.main.bounds.height*0.04).padding(.horizontal)
                 Text(userData.LocalUser?.PersonalStatus == true ? "You’re currently NOT\nHome Safe" : "You’re currently \nHome Safe"  ).foregroundColor(Color(userData.LocalUser?.PersonalStatus == false ? accentRed : accentGreen)).font(.title).fontWeight(.bold).padding(.leading)
                Spacer()
                Button(action: {
                    userData.pushPersonalStatus(Id: Auth.auth().currentUser!.uid, NewPersonalStatus: !(userData.LocalUser!.PersonalStatus))
                }, label: {
                    BottomButton(text: (userData.LocalUser?.PersonalStatus == true ? "I'm Home Safe" : "I'm NOT Home Safe"), strokeColor: Color(accentGreen), backgroundColor: Color(accentRed), textColor: Color(accentGreen))
                }).padding(.horizontal,44).padding(.bottom,24)
                 
            }.frame(height: UIScreen.main.bounds.height/2).background(Color(userData.LocalUser?.PersonalStatus == false ?  accentGreen : accentRed))
        
        if(userData.LocalUser?.PartnerCode != ""){
            Rectangle().frame(height: 10).foregroundColor(Color(accentGrey))
            VStack(alignment: .leading){
               HStack{
                   Text(userData.PartnerStatus == false ? "Your partner is currently \nHome Safe" : "Your partner is currently NOT\nHome Safe").foregroundColor(Color(userData.PartnerStatus == false ? accentRed : accentGreen)).font(.title).fontWeight(.bold).padding(.leading)
                   Spacer()
               }.padding(.top, 21)
       
               Spacer()
               
               Button(action: {
                   removeAlertShown = true
               }, label: {
                    BottomButton(text: "Remove Partner", strokeColor: Color(accentGreen), backgroundColor: Color(accentRed), textColor: Color(accentGreen))
               }).padding(.horizontal,44).padding(.bottom,46)
           }.frame(height: UIScreen.main.bounds.height/2).background(Color(userData.PartnerStatus == false ? accentGreen : accentRed))
            .onAppear(perform: {
                if(userData.LocalUser?.PartnerCode.count ?? 0 > 0){
                    userData.getPartnerStatus(Id: userData.LocalUser?.PartnerCode ?? "")
                }
            })
            
        }
        else{
            Rectangle().frame(height: 10).foregroundColor(Color(accentGrey))
            VStack(alignment: .leading){
               HStack{
                   Text("Your code is: \n\(userData.LocalUser?.PersonalCode ?? "")").foregroundColor(Color(accentGreen)).font(.title).fontWeight(.bold).padding(.leading)
                   Spacer()
               }.padding(.top, 21)
               Spacer()
                TextFieldCustom(code: $code).padding(.leading).padding(.trailing).padding(.trailing)
               Spacer()
               Button(action: {
                   userData.matchPartner(PartnerCode: code)
               }, label: {
                    BottomButton(text: "Add Partner", strokeColor: Color(accentGreen), backgroundColor: Color(accentRed), textColor: Color(accentGreen))
               }).padding(.horizontal,44).padding(.bottom,46)
           }.frame(height: UIScreen.main.bounds.height/2).background(Color(accentRed))
        }
        }.ignoresSafeArea(.all).navigationBarHidden(true)
        .alert(isPresented: $removeAlertShown, content: {
            Alert(
                 title: Text("Unmatch partner"),
                 message: Text("Did you break up or is this by accident?"),
                 primaryButton: .destructive(Text("Maybe?"), action: {
                     userData.unMatchPartner(PartnerCode: userData.LocalUser!.PartnerCode)
                     self.removeAlertShown = false
                 }),
                 secondaryButton: .default(Text("Accident"), action: {
                     self.removeAlertShown = false
                 })
             )
        })
    }
}

struct Background: View{
    var colorTop: Color
    var colorBottom: Color
    var body: some View{
        VStack(spacing: 0){
        Rectangle().frame(height: UIScreen.main.bounds.height/2, alignment: .center).foregroundColor(colorTop)
        Rectangle().frame(height: 10).foregroundColor(Color(accentGrey))
        Rectangle().frame(height: UIScreen.main.bounds.height/2, alignment: .center).foregroundColor(colorBottom)
        }
    }
}
struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
