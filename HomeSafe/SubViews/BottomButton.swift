//
//  BottomButton.swift
//  HomeSafeUI
//
//  Created by Calin Teodor on 22.02.2022.
//

import SwiftUI

struct BottomButton: View {
    var text : String
    var strokeColor: Color
    var backgroundColor: Color
    var textColor: Color
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 34).foregroundColor(strokeColor).frame(height: 64)
            RoundedRectangle(cornerRadius: 34).foregroundColor(backgroundColor).frame(height: 60).padding(.horizontal,2)
            Text(text).foregroundColor(textColor).font(.title).fontWeight(.bold)
        }
        
    }

}

struct BottomButton_Previews: PreviewProvider {
    static var previews: some View {
        BottomButton(text: "Match with",strokeColor: Color(accentGreen), backgroundColor: Color(accentRed), textColor: Color(accentGreen))
    }
}
