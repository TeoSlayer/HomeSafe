//
//  HomeSafeApp.swift
//  HomeSafe
//
//  Created by Calin Teodor on 21.02.2022.
//

import SwiftUI

@main
struct HomeSafeApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
