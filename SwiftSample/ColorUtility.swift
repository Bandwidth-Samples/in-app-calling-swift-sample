import SwiftUI

// MARK: - UIColor Extension

extension UIColor {
    
    /// Returns the color corresponding to the provided name or black if not found.
    ///
    /// This function looks up a color by its name and, if not found, provides a default fallback (black).
    ///
    /// - Parameter name: The name of the color to look up.
    /// - Returns: The `UIColor` corresponding to the given name or `UIColor.black` if not found.
    static func namedOrBlack(_ name: String) -> UIColor {
        return UIColor(named: name) ?? UIColor.black
    }
    
    /// A named color (or fallback) representing "bandwidthBlack".
    static var bwBlack: UIColor { namedOrBlack("bandwidthBlack") }
    
    /// A named color (or fallback) representing "bandwidthBlue".
    static var bwBlue: UIColor { namedOrBlack("bandwidthBlue") }
    
    /// A named color (or fallback) representing "bandwidthBlueDark".
    static var bwBlueDark: UIColor { namedOrBlack("bandwidthBlueDark") }
    
    /// A named color (or fallback) representing "bandwidthGray".
    static var bwGray: UIColor { namedOrBlack("bandwidthGray") }
    
    /// A named color (or fallback) representing "bandwidthGrayDark".
    static var bwGrayDark: UIColor { namedOrBlack("bandwidthGrayDark") }
    
    /// A named color (or fallback) representing "bandwidthGreen".
    static var bwGreen: UIColor { namedOrBlack("bandwidthGreen") }
    
    /// A named color (or fallback) representing "bandwidthRed".
    static var bwRed: UIColor { namedOrBlack("bandwidthRed") }
    
    /// A named color (or fallback) representing "bandwidthWhite".
    static var bwWhite: UIColor { namedOrBlack("bandwidthWhite") }
}

// MARK: - Color Extension

extension Color {

    /// A named color (or fallback) representing "bandwidthBlack".
    static var bwBlack: Color { Color(UIColor.bwBlack) }
    
    /// A named color (or fallback) representing "bandwidthBlue".
    static var bwBlue: Color { Color(UIColor.bwBlue) }
    
    /// A named color (or fallback) representing "bandwidthBlueDark".
    static var bwBlueDark: Color { Color(UIColor.bwBlueDark) }
    
    /// A named color (or fallback) representing "bandwidthGray".
    static var bwGray: Color { Color(UIColor.bwGray) }
    
    /// A named color (or fallback) representing "bandwidthGrayDark".
    static var bwGrayDark: Color { Color(UIColor.bwGrayDark) }
    
    /// A named color (or fallback) representing "bandwidthGreen".
    static var bwGreen: Color { Color(UIColor.bwGreen) }
    
    /// A named color (or fallback) representing "bandwidthRed".
    static var bwRed: Color { Color(UIColor.bwRed) }
    
    /// A named color (or fallback) representing "bandwidthWhite".
    static var bwWhite: Color { Color(UIColor.bwWhite) }
}
