//
//  ContentView.swift
//  SampleApp
//
//  Created by Melvin Salas on 10/05/2023.
//

import SwiftUI
import AlertToast
import BandwidthSDK

/// Represents the main content view of the application.
struct ContentView: View {
    @Binding var phoneNumber: String
    @Binding var callState: CallState
    @Binding var isMuted: Bool
    @Binding var isHolded: Bool
    @State private var resultFromRingingScreen: String = ""
    @State private var isSecondViewActive: Bool = false
    @State private var showToast = false
    var makeCall: () -> Void
    var terminateCall: () -> Void
    var onMuteCallback: () -> Void
    var onHoldCallback: () -> Void
    var onSendDTMF: (DTMF) -> Void
    
    /// Initializes the content view with the given call details.
    /// - Parameters:
    ///   - phoneNumber: The phone number.
    ///   - callState: The call state.
    ///   - isMuted: A boolean indicating whether the call is muted.
    ///   - isHolded: A boolean indicating whether the call is on hold.
    ///   - makeCall: The closure to make a call.
    ///   - terminateCall: The closure to terminate a call.
    ///   - onMuteCallback: The callback for muting/unmuting the call.
    ///   - onHoldCallback: The callback for placing the call on hold/unhold.
    init(phoneNumber: Binding<String>,
         callState: Binding<CallState>,
         isMuted: Binding<Bool>,
         isHolded: Binding<Bool>,
         makeCall: @escaping () -> Void,
         terminateCall: @escaping () -> Void,
         onMuteCallback: @escaping () -> Void,
         onHoldCallback: @escaping () -> Void,
         onSendDTMF: @escaping (DTMF) -> Void
    ) {
        self._phoneNumber = phoneNumber
        self._callState = callState
        self._isMuted = isMuted
        self._isHolded = isHolded
        self.makeCall = makeCall
        self.terminateCall = terminateCall
        self.onMuteCallback = onMuteCallback
        self.onHoldCallback = onHoldCallback
        self.onSendDTMF = onSendDTMF
        UINavigationBar.applyCustomAppearance()
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                StatusView(callState: $callState,
                           isMuted: $isMuted,
                           isHolded: $isHolded,
                           onMuteCallback: self.onMuteCallback,
                           onHoldCallback: self.onHoldCallback)
                CustomTextField(phoneNumber: $phoneNumber)
                Spacer()
                GridButtonsView(phoneNumber: $phoneNumber,
                                showToast: $showToast,
                                callState: $callState,
                                makeCall: self.makeCall,
                                terminateCall: self.terminateCall,
                                onSendDTMF: self.onSendDTMF)
                Spacer()
                NavigationLink( destination: RingingView(result: $resultFromRingingScreen, number: $phoneNumber),isActive: $isSecondViewActive){
                    Text("Go to Second Screen")
                        .font(.title)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }.onChange(of: isSecondViewActive){newValue in
                    if !newValue {
                        print(resultFromRingingScreen)
                        // Place additional actions here if needed
                    }}
            }
            .padding()
            .navigationBarTitle("Sample App", displayMode: .inline)
        }
        .toast(isPresenting: $showToast) {
            AlertToast(displayMode: .hud, type: .error(.red), title: "The phone number must not be empty")
        }
    }
}

/// Represents a custom button with an icon and text.
struct CustomButton: View {
    let systemName: String
    let text: String
    let active: Bool
    let disabled: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: actionIfEnabled) {
            HStack {
                Image(systemName: systemName)
                    .foregroundColor(disabled ? .bwGrayDark : .bwBlue)
                Text(text)
                    .foregroundColor(disabled ? .bwGrayDark : .bwBlue)
            }
        }
        .disabled(disabled)
    }
    
    private func actionIfEnabled() {
        if !disabled {
            self.action()
        }
    }
}


extension ContentView {
    /// Represents the current status view.
    struct StatusView: View {
        @Binding var callState: CallState
        @Binding var isMuted: Bool
        @Binding var isHolded: Bool
        var onMuteCallback: () -> Void
        var onHoldCallback: () -> Void
        
        var body: some View {
            HStack {
                Text("Status:")
                Text(currentStatusText)
                Spacer()
                CustomButton(systemName: "mic.fill", text: muteButtonText, active: isMuted, disabled: isDisabled(), action: onMuteCallback)
                CustomButton(systemName: "pause.fill", text: holdButtonText, active: isHolded, disabled: isDisabled(), action: onHoldCallback)
            }
        }
        
        private func isDisabled() -> Bool {
            return callState != .connected
        }
        
        private var currentStatusText: String {
            return isMuted ? "Mute" : (isHolded ? "On hold" : callState.description)
        }
        
        private var muteButtonText: String {
            return isMuted ? "Unmute" : "Mute"
        }
        
        private var holdButtonText: String {
            return isHolded ? "Unhold" : "Hold"
        }
    }
    
    /// Represents a custom text field for adding a phone number.
    struct CustomTextField: View {
        @Binding var phoneNumber: String
        
        var body: some View {
            VStack(alignment: .center, spacing: 10) {
                Text("Add number".uppercased())
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(Color.bwBlue)
                
                HStack {
                    Image(systemName: "plus")
                        .foregroundColor(.bwGrayDark)
                        .padding(.leading, 8)
                    
                    if phoneNumber.isEmpty {
                        Text("Phone number")
                            .font(.title3)
                            .foregroundColor(Color.bwGrayDark)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        Text(phoneNumber)
                            .font(.title3)
                            .foregroundColor(Color.bwBlack)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    Spacer()
                }
                .padding(10)
                .overlay(
                    Rectangle()
                        .stroke(Color.bwGrayDark, lineWidth: 1)
                )
                .frame(maxWidth: .infinity)
                
                Text("Add e163 number format")
                    .font(.footnote)
                    .italic()
                    .foregroundColor(.bwGrayDark)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

/// Represents a grid of buttons.
struct GridButtonsView: View {
    @Binding var phoneNumber: String
    @Binding var showToast: Bool
    @Binding var callState: CallState
    var makeCall: () -> Void
    var terminateCall: () -> Void
    var onSendDTMF: (DTMF) -> Void
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 10),
            GridItem(.flexible(), spacing: 10),
            GridItem(.flexible(), spacing: 10)
        ], spacing: 10) {
            AppDialButton(title: "1", action: { pushDial(.one) })
            AppDialButton(title: "2", text: "ABC") { pushDial(.two) }
            AppDialButton(title: "3", text: "DEF", action: { pushDial(.three) })
            AppDialButton(title: "4", text: "GHI", action: { pushDial(.four) })
            AppDialButton(title: "5", text: "JKL", action: { pushDial(.five) })
            AppDialButton(title: "6", text: "MNO", action: { pushDial(.six) })
            AppDialButton(title: "7", text: "PQRS", action: { pushDial(.seven) })
            AppDialButton(title: "8", text: "TUV", action: { pushDial(.eight) })
            AppDialButton(title: "9", text: "WXYZ", action: { pushDial(.nine) })
            AppDialButton(icon: "asterisk", action: {pushDial(.star) })
            AppDialButton(title: "0", text: "+", action: { pushDial(.zero) })
            AppDialButton(icon: "number", action: { pushDial(.pound)})
            AppDialButton().blank()
            AppDialButton(icon: "phone.fill", style: callButtonStyle(), action: callAction)
            AppDialButton(icon: "delete.left.fill", style: .clear, action: { popNumber() })
        }
        .padding(.horizontal, 40)
    }
    
    private func callButtonStyle() -> AppDialButtonStyle {
        switch callState {
        case .null:
            return .green
        case .calling:
            return .gray
        default:
            return .red
        }
    }
    
    private func callAction() -> Void {
        switch callState {
        case .null:
            if phoneNumber.isEmpty {
                showToast.toggle()
            } else {
                makeCallIfPossible()
            }
        case .calling:
            // No action to be taken in the calling state
            break
        default:
            terminateCall()
        }
    }
    
    private func pushDial(_ dial: DTMF) {
        switch callState {
        case .null:
            phoneNumber += dial.rawValue
        case .connected:
            onSendDTMF(dial)
        default: break
        }
    }
    
    private func popNumber() {
        if !phoneNumber.isEmpty {
            phoneNumber.removeLast()
        }
    }
    
    private func makeCallIfPossible() {
        guard !phoneNumber.isEmpty else {
            showToast.toggle()
            return
        }
        makeCall()
    }
}
