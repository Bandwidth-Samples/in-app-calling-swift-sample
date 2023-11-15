//
//  AppDialButton.swift
//  sample
//
//  Created by Melvin Salas on 5/10/23.
//

import SwiftUI

// MARK: - AppDialButton

/// A custom SwiftUI button with various styling options.
struct AppDialButton: View {
    // MARK: Properties
    let title: String
    let icon: String
    let text: String
    let style: AppDialButtonStyle
    let action: () -> Void
    let void: Bool
    let frameSize: CGFloat = 50
    let titleSize: CGFloat = 32
    let iconSize: CGFloat = 30
    let textSize: CGFloat = 14
    let strokeWidth: CGFloat = 4
    
    // MARK: Initializer
    
    /// Initializes a new `AppDialButton` with a title, icon, text, style, and action.
    /// - Parameters:
    ///   - title: The title for the button.
    ///   - icon: The name of the SF Symbol for the button's icon.
    ///   - text: The text displayed below the title.
    ///   - style: The style of the button.
    ///   - action: A closure to execute when the button is tapped.
    init(title: String = "",
         icon: String = "",
         text: String = "",
         style: AppDialButtonStyle = .blueBorder,
         action: @escaping () -> Void = {},
         void: Bool = false
   ) {
       self.title = title
       self.icon = icon
       self.text = text
       self.style = style
       self.action = action
       self.void = void
   }
    
    // MARK: Body
        
    var body: some View {
        if(void) {
            Spacer(minLength: frameSize)
        } else {
            Button(action: {
                self.action()
            }) {
                VStack {
                    if !title.isEmpty {
                        Text(title)
                            .font(.system(size: titleSize))
                    }
                    if !icon.isEmpty {
                        Image(systemName: icon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: iconSize, height: iconSize)
                    }
                    if !text.isEmpty {
                        Text(text)
                            .font(.system(size: textSize))
                    }
                }
                .frame(width: frameSize, height: frameSize)
            }
            .padding()
            .overlay(
                Circle()
                    .stroke(self.strokeColor(), lineWidth: strokeWidth)
            )
            .background(self.backgroundColor())
            .foregroundColor(self.textColor())
            .clipShape(Circle())
        }
    }
    
    // MARK: Private Methods
      
    private func strokeColor() -> Color {
        switch style {
        case .blueBorder:
            return Color.bwBlueDark
        case .green:
            return Color.bwGreen
        case .red:
            return Color.bwRed
        case .gray:
            return Color.bwGrayDark
        case .clear:
            return .clear
        }
    }

    private func backgroundColor() -> Color {
        switch style {
        case .blueBorder:
            return .clear
        case .green:
            return Color.bwGreen
        case .red:
            return Color.bwRed
        case .gray:
            return Color.bwGrayDark
        case .clear:
            return .clear
        }
    }

    private func textColor() -> Color {
        switch style {
        case .blueBorder:
            return Color.bwBlueDark
        case .green:
            return Color.bwWhite
        case .red:
            return Color.bwWhite
        case .gray:
            return Color.bwWhite
        case .clear:
            return Color.bwGray
        }
    }

}

extension AppDialButton {
    func blank() -> AppDialButton {
        return AppDialButton(void: true)
    }
}

// MARK: - AppDialButtonStyle

/// An enumeration representing different styles for `AppDialButton`.

enum AppDialButtonStyle {
    case blueBorder
    case green
    case red
    case gray
    case clear
}

// MARK: - AppDialButton_Previews


struct AppDialButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Example previews
            AppDialButton(title: "1", icon: "", text: "", style: .blueBorder, action: { })
                .previewLayout(.sizeThatFits)
                .padding()
            
            AppDialButton(title: "2", icon: "", text: "ABC", style: .blueBorder, action: { })
                .previewLayout(.sizeThatFits)
                .padding()
            
            AppDialButton(title: "", icon: "asterisk", text: "", style: .blueBorder, action: { })
                .previewLayout(.sizeThatFits)
                .padding()
            
            AppDialButton(title: "", icon: "phone.fill", text: "", style: .green, action: { })
                .previewLayout(.sizeThatFits)
                .padding()
            
            AppDialButton(title: "", icon: "phone.fill", text: "", style: .red, action: { })
                .previewLayout(.sizeThatFits)
                .padding()
            
            AppDialButton(title: "", icon: "phone.fill", text: "", style: .gray, action: { })
                .previewLayout(.sizeThatFits)
                .padding()
            
            AppDialButton(title: "", icon: "delete.left.fill", text: "", style: .clear, action: { })
                .previewLayout(.sizeThatFits)
                .padding()
            
            AppDialButton().blank()
                .previewLayout(.sizeThatFits)
                .padding()
        }
    }
}
