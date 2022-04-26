//
//  TextField.swift
//  HomeSafeUI
//
//  Created by Calin Teodor on 22.02.2022.
//

import SwiftUI

struct TextFieldCustom: View {
    @Binding var code: String
    var body: some View {
        VStack(alignment: .leading){
            TextField("", text: $code)
                .placeholder(when: code.isEmpty) {
                    Text("Add Partner Code ... ")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color(accentGreen))
                }
                .foregroundColor(Color(accentGreen))
                .font(.title)
            Rectangle()
                .foregroundColor(Color(accentGreen))
                .frame(height: 10)
                .padding(.top, 18)
            
        }
    }
}

struct TextFieldCustom_Previews: PreviewProvider {
    static var previews: some View {
        TextFieldCustom(code: .constant("Text"))
    }
}
