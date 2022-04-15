//
//  RefreshButton.swift
//  HomeSafeUI
//
//  Created by Calin Teodor on 22.02.2022.
//

import SwiftUI

struct RefreshButton: View {
    var body: some View {
        Image("Refresh").resizable().frame(width: 30, height: 30, alignment: .center)
    }
}

struct RefreshButton_Previews: PreviewProvider {
    static var previews: some View {
        RefreshButton()
    }
}
