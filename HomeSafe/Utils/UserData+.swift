//
//  UserData+.swift
//  HomeSafe
//
//  Created by Calin Teodor on 22.02.2022.
//

import Foundation

class SharedUserData : ObservableObject{
    static let Shared = SharedUserData()
    init(){}
    @Published var LocalUser  = User(Id: "", PersonalCode: "", PartnerCode: "", Email: "", PersonalStatus: true)
    @Published var PartnerStatus : Bool = false
    
    private func EmptyUser() -> User {
        let user = User(Id: "", PersonalCode: "", PartnerCode: "", Email: "", PersonalStatus: true)
        return user
    }
    
}
