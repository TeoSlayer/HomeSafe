//
//  HomeSafeApp.swift
//  HomeSafe
//
//  Created by Calin Teodor on 21.02.2022.
//

import SwiftUI
import UIKit
import CoreData
import Firebase
import FirebaseAuth
import OneSignal
import Sentry


@main
struct HomeSafeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(UserData.Shared)
                .onAppear(perform: UIApplication.shared.addTapGestureRecognizer)
        }
    }
}

extension UIApplication {
    func addTapGestureRecognizer() {
        guard let window = windows.first else { return }
        let tapGesture = UITapGestureRecognizer(target: window, action: #selector(UIView.endEditing))
        tapGesture.requiresExclusiveTouchType = false
        tapGesture.cancelsTouchesInView = false
        window.addGestureRecognizer(tapGesture)
    }
}


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
      FirebaseApp.configure()
    
      
      OneSignal.setLogLevel(.LL_VERBOSE, visualLevel: .LL_NONE)
      OneSignal.initWithLaunchOptions(launchOptions)
      OneSignal.setAppId("8c983689-90d2-4070-81c9-446e7bb29c99")
      SentrySDK.start { options in
              options.dsn = "https://afb328aaf7e34058bb6004b41955324f@o1149862.ingest.sentry.io/6222304"
              options.debug = false // Enabled debug when first installing is always helpful

              // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
              // We recommend adjusting this value in production.
              options.tracesSampleRate = 1.0
      }

       // promptForPushNotifications will show the native iOS notification permission prompt.
       // We recommend removing the following code and instead using an In-App Message to prompt for notification permission (See step 8)
      OneSignal.promptForPushNotifications(userResponse: { accepted in
         print("User accepted notifications: \(accepted)")
       })
      if(Auth.auth().currentUser?.uid != nil){
          UserData.Shared.RetrieveUser(UserId: Auth.auth().currentUser!.uid)
          if let deviceState = OneSignal.getDeviceState() {
              let userId = deviceState.userId
              print("OneSignal Push Player ID: ", userId ?? "called too early, not set yet")
              let subscribed = deviceState.isSubscribed
              print("Device is subscribed: ", subscribed)
              let hasNotificationPermission = deviceState.hasNotificationPermission
              print("Device has notification permissions enabled: ", hasNotificationPermission)
              let notificationPermissionStatus = deviceState.notificationPermissionStatus
              print("Device's notification permission status: ", notificationPermissionStatus.rawValue)
              let pushToken = deviceState.pushToken
              print("Device Push Token Identifier: ", pushToken ?? "no push token, not subscribed")
          }
      }
    print("Application is starting up. ApplicationDelegate didFinishLaunchingWithOptions.")
    return true
  }

 
  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    print("\(#function)")
    Auth.auth().setAPNSToken(deviceToken, type: .sandbox)
  }
  
  func application(_ application: UIApplication, didReceiveRemoteNotification notification: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    print("\(#function)")
    if Auth.auth().canHandleNotification(notification) {
      completionHandler(.noData)
      return
    }
  }
  
  
  func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
    print("\(#function)")
    if Auth.auth().canHandle(url) {
      return true
    }
    return false
  }
}

