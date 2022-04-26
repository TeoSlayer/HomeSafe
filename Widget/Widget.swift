//
//  Widget.swift
//  Widget
//
//  Created by Calin Teodor on 22.02.2022.
//

import WidgetKit
import SwiftUI
import Intents
import Firebase
import FirebaseAuth
import FirebaseFirestore
import Foundation
import UIKit

let accentRed = UIColor(rgb: 0xEE4266)
let accentPurple = UIColor(rgb: 0x2A1E5C)
let accentGrey = UIColor(rgb: 0xC4CBCA)
let accentGreen = UIColor(rgb: 0x3CBBB1)

//Colors
extension UIColor {
   convenience init(red: Int, green: Int, blue: Int) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")

       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }

   convenience init(rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
}



struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent(), statusData: UserStatus(partnerStatus: true, matchedStatus: true, loginStatus: true, error: ""))
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration, statusData: UserStatus(partnerStatus: true, matchedStatus: true, loginStatus: true, error: ""))
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        
        let date = Date()
        
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: date)
        
        fetchFirebase{ stat in
            
            let entry = SimpleEntry(date: date, configuration: configuration, statusData: stat)
            
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate!))
            
            completion(timeline)
            
        }
    }
    
    func fetchFirebase(completion: @escaping (UserStatus) -> ()){
        
        let defaults = UserDefaults(suiteName: "group.io.usergy.HomeSafe")
        //read uid from defaults
        let uid = defaults?.string(forKey: "uid")

        if(uid == "" || uid == nil){
            completion(UserStatus(partnerStatus: false, matchedStatus: false, loginStatus: false, error: "Please Log In"))
            return
        }
        
        let db = Firestore.firestore().collection("Users").document(uid!)
        
        db.getDocument(completion: { snap, err in
            guard let doc = snap?.data() else{
                completion(UserStatus(partnerStatus: false, matchedStatus: false, loginStatus: false, error: "Error while finding your profile!"))
                return
            }

            let partnercode = doc["PartnerCode"] as? String ?? ""
            
            if(partnercode == "" || partnercode == nil){
                completion(UserStatus(partnerStatus: false, matchedStatus: false, loginStatus: true, error: "Your're not matched yet!"))
            }
            
            let dbpartner = Firestore.firestore().collection("Users").document(partnercode)
            
            
            dbpartner.getDocument(completion: { snapshot, error in
                guard let docpartner = snap?.data() else{
                    completion(UserStatus(partnerStatus: false, matchedStatus: false, loginStatus: true, error: "Error while finding your partner's profile!"))
                    return
                }
                
                let partnerLiveStatus = docpartner["PersonalStatus"] as? Bool ?? false
                
                completion(UserStatus(partnerStatus: partnerLiveStatus, matchedStatus: true, loginStatus: true, error: ""))
            })
        
        })
    }
}

struct UserStatus {
    var partnerStatus: Bool
    var matchedStatus: Bool
    var loginStatus: Bool
    var error: String
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    let statusData: UserStatus
}

struct WidgetEntryView : View {
    @Environment(\.widgetFamily) var family
    var entry: Provider.Entry

    var body: some View {
        switch family {
                case .systemSmall:
                    SmallWidget(entry: entry)
                case .systemMedium:
                    MediumWidget(entry: entry)
                default:
                    Text("Some other WidgetFamily in the future.")
                }
        
        
    }
}

struct SmallWidget : View {
    var entry: Provider.Entry
    var body: some View{
        if(entry.statusData.error != "")
        {
            ZStack{
                Text(entry.statusData.error).foregroundColor(Color(accentGreen)).font(.title).fontWeight(.bold).padding(.leading)
            }.frame(maxWidth: .infinity, maxHeight: .infinity).ignoresSafeArea(.all).background(Color(accentRed))
        }
        else{
            ZStack{
                Text(entry.statusData.partnerStatus == false ? "Your partner is currently \nHome Safe" : "Your partner is currently NOT\nHome Safe").foregroundColor(Color(entry.statusData.partnerStatus == false ? accentRed : accentGreen)).font(.title2).fontWeight(.bold).padding(.leading)
               
            }.frame(maxWidth: .infinity, maxHeight: .infinity).ignoresSafeArea(.all).background(Color(entry.statusData.partnerStatus == false ? accentGreen : accentRed))

            
        }
    }
}

struct MediumWidget : View {
    var entry: Provider.Entry
    var body: some View{
        if(entry.statusData.error != "")
        {
            ZStack{
                Text(entry.statusData.error).foregroundColor(Color(accentGreen)).font(.title).fontWeight(.bold).padding(.leading)
            }.frame(maxWidth: .infinity, maxHeight: .infinity).ignoresSafeArea(.all).background(Color(accentRed))
        }
        else{
            ZStack{
                Text(entry.statusData.partnerStatus == false ? "Your partner is currently \nHome Safe" : "Your partner is currently NOT\nHome Safe").foregroundColor(Color(entry.statusData.partnerStatus == false ? accentRed : accentGreen)).font(.title).fontWeight(.bold).padding(.leading)
               
            }.frame(maxWidth: .infinity, maxHeight: .infinity).ignoresSafeArea(.all).background(Color(entry.statusData.partnerStatus == false ? accentGreen : accentRed))

            
        }
    }
}



@main
struct MainWidget: Widget {
    init(){
        FirebaseApp.configure()
    }
    
    let kind: String = "Widget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            WidgetEntryView(entry: entry)
        }
        .supportedFamilies([.systemSmall, .systemMedium])
        .configurationDisplayName("HomeSafe Widget")
        .description("View if your partner is home safe")
    }
}

struct Widget_Previews: PreviewProvider {
    static var previews: some View {
        WidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), statusData: UserStatus(partnerStatus: true, matchedStatus: true, loginStatus: true, error: "")))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
