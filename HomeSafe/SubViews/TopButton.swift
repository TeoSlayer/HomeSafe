//
//  TopButtons.swift
//  HomeSafeUI
//
//  Created by Calin Teodor on 22.02.2022.
//

import SwiftUI

struct TopButton: View {
    var text : String
    var strokeColor: Color
    var backgroundColor: Color
    var textColor: Color
    var body: some View {
        Text(text).font(.body).foregroundColor(textColor).padding(.vertical, 8).padding(.horizontal,13)
                .overlay(RoundedRectangle(cornerRadius: 15)
                            .stroke(strokeColor, lineWidth: 2))
                .background(backgroundColor).cornerRadius(15)
            
    }
}

struct TopButton_Previews: PreviewProvider {
    static var previews: some View {
        TopButton(text: "Log Off",strokeColor: Color(accentGreen), backgroundColor: Color(accentRed), textColor: Color(accentGreen))
    }
}
