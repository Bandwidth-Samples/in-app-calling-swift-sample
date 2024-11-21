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
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Text("Call from +9198765555")
                .font(.title)
                .foregroundColor(Color.white)
                .padding(EdgeInsets(top: 60, leading: 10, bottom: 20, trailing: 10))
            Spacer()
            HStack(content: {
                Button(action: {
                    print("Accept")
                    result = "Result received from Second Screen = Accept"
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Accept")
                        .font(.title)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                Spacer()
                Button(action: {
                    result = "Result received from Second Screen = Declined"
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Declined")
                        .font(.title)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

            }).padding(EdgeInsets(top: 40, leading: 30, bottom: 60, trailing: 30))
        }
        .padding().background(Color.black).navigationBarHidden(true)
    }
}
