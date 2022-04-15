//
//  ContentView.swift
//  HomeSafe
//
//  Created by Calin Teodor on 21.02.2022.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @EnvironmentObject var userData : UserData
    var body: some View {
        NavigationView {
            if(userData.LoggedIn){
                Home()
                    .environmentObject(UserData.Shared)
            }
            else{
                Login()
            }
        }
    }
}
