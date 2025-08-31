//
//  Color+Extension.swift
//  CryptoBro
//
//  Created by Sergey on 22.08.25.
//

import SwiftUI

// A struct to hold all the colors for our app's theme.
struct ColorTheme {
    let accent = Color("AccentColor")
    let background = Color("BackgroundColor")
    let green = Color("GreenColor")
    let red = Color("RedColor")
    let primaryText = Color("PrimaryTextColor")
    let secondaryText = Color("SecondaryTextColor")
}

// An extension on Color to make accessing our theme easy.
// We can now use colors like `Color.theme.background`.
extension Color {
    static let theme = ColorTheme()
}
