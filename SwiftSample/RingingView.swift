//
//  RingingView.swift
//  SwiftSample
//
//  Created by User on 13/11/24.
//

import Foundation
import SwiftUI

struct RingingView: View {
    @Binding var result: String
    @Binding var number: String
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Text("Call from +"+number)
                .font(.title.bold())
                .foregroundColor(Color.white)
                .padding(EdgeInsets(top: 60, leading: 10, bottom: 20, trailing: 10))
            Spacer()
            HStack(content: {
                AppDialButton(icon: "phone.fill", style: AppDialButtonStyle.green, action: {
                    print("Accept")
                    NotificationCenter.default.post(name: NSNotification.Name("AcceptCall"), object: nil)
                }).padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0))
                Spacer()
                AppDialButton(icon: "phone.down.fill", style: AppDialButtonStyle.red,action: {
                    print("Declined")
                    NotificationCenter.default.post(name: NSNotification.Name("DeclinedCall"), object: nil)
                }).padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 20))
            }).padding(EdgeInsets(top: 40, leading: 30, bottom: 60, trailing: 30))
        }
        .padding().background(Color.black).navigationBarHidden(true)
    }
}
