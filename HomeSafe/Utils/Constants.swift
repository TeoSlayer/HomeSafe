//
//  Constants.swift
//  HomeSafe
//
//  Created by Calin Teodor on 22.02.2022.
//

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
