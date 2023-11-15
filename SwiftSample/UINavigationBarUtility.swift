//
//  UINavigationBarUtility.swift
//  sample
//
//  Created by Melvin Salas on 6/10/23.
//

import Foundation
import SwiftUI

/// An extension on `UINavigationBar` providing a utility function to apply a custom appearance.
extension UINavigationBar {
    
    /// Applies a custom appearance to the navigation bar, setting its background color and title text attributes.
    ///
    /// This function sets the background color to a predefined blue-dark color (`bwBlueDark`) and the title text attributes to white color (`bwWhite`).
    ///
    /// Call this function to ensure consistent styling of the navigation bar throughout the application.
    static func applyCustomAppearance() {
        let appearance = UINavigationBarAppearance()
        
        // Set the background color of the navigation bar
        appearance.backgroundColor = UIColor.bwBlueDark
        
        // Set the title text attributes (text color) to white
        appearance.titleTextAttributes = [.foregroundColor: UIColor.bwWhite]
        
        // Apply the custom appearance to different states of the navigation bar
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}
