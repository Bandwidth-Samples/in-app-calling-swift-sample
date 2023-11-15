//
//  SwiftSampleApp.swift
//  SwiftSample
//
//  Created by Melvin Salas on 23/10/23.
//

import SwiftUI
import BandwidthSDK

@main
struct SwiftSampleApp: App {
    @State private var phoneNumber = ""
    @State private var isMuted = false
    @State private var isHolded = false
    @State private var session: BandwidthSession? = nil
    @State private var callState: CallState = .null

    private let bandwidthUA = BandwidthUA()

    var body: some Scene {
        WindowGroup {
            ContentView(
                phoneNumber: $phoneNumber,
                callState: $callState,
                isMuted: $isMuted,
                isHolded: $isHolded,
                makeCall: makeCall,
                terminateCall: terminateCall,
                onMuteCallback: onMuteCallback,
                onHoldCallback: onHoldCallback,
                onSendDTMF: onSendDTMF
            )
        }
    }

    /// Terminates the active call.
    func terminateCall() {
        if let session = session {
            resetCallState()
            session.terminate()
        }
    }

    /// Toggles the mute state of the call and updates the BandwidthUA session.
    func onMuteCallback() {
        if let session = session {
            isMuted.toggle()
            session.muteAudio(mute: isMuted)
        }
    }

    /// Toggles the hold state of the call and updates the BandwidthUA session.
    func onHoldCallback() {
        if let session = session {
            isHolded.toggle()
            session.hold(hold: isHolded)
        }
    }

    /// Initiates a call using BandwidthUA.
    func makeCall() {
        configureBandwidthUA()
        let formatPhoneNumber = "+" + phoneNumber
        session = bandwidthUA.makeCall(formatPhoneNumber, domain: extractStringValue(forKey: .connectionDomain))
        if let session = session {
            session.addSessionEventListener(listener: self)
        } else {
            fatalError("Failed to create a session.")
        }
    }
    
    /// Send DTMF to session, if avaibale
    func onSendDTMF(dtmf: DTMF) {
        if let session = session {
            session.sendDTMF(dtmf: dtmf)
        } else {
            fatalError("Failed to create a session.")
        }
    }

    /// Resets the call state, including phone number, mute, and hold.
    private func resetCallState() {
        callState = .null
        phoneNumber = ""
        isMuted = false
        isHolded = false
    }

    /// Configures the BandwidthUA instance.
    private func configureBandwidthUA() {
        do {
            try bandwidthUA.configureAudioCodesUA(proxyAddress: extractStringValue(forKey: .connectionDomain),
                                              serverDomain: extractStringValue(forKey: .connectionDomain),
                                              port: Int32(extractIntValue(forKey: .connectionPort)),
                                              transport: .tls,
                                              logLevel: .verbose)
            
            try bandwidthUA.configureOAuthAuthentication(username: extractStringValue(forKey: .accountUsername),
                                                     displayName: extractStringValue(forKey: .accountDisplayName),
                                                     password: extractStringValue(forKey: .accountPassword),
                                                     authName: extractStringValue(forKey: .accountUsername),
                                                     connectionUrl: extractStringValue(forKey: .connectionToken),
                                                     headerUser: extractStringValue(forKey: .connectionHeaderUser),
                                                     headerPass: extractStringValue(forKey: .connectionHeaderPass))
        } catch {
            // Handle the error here
            print("An error occurred: \(error)")
        }
    }
}

extension SwiftSampleApp: BandwidthSessionEventListener {
    /// Called when a call is terminated.
    /// - Parameter session: The BandwidthSession object for the terminated call.
    func callTerminated(session: BandwidthSession?) {
        resetCallState()
        bandwidthUA.logout()
    }

    /// Called when a call is in progress.
    /// - Parameter session: The BandwidthSession object for the ongoing call.
    func callProgress(session: BandwidthSession?) {
        if let session = session {
            callState = session.callState
        }
    }

    /// Called when an incoming notification is received.
    /// - Parameters:
    ///   - event: The NotifyEvent received.
    ///   - dtmfValue: The DTMF value received, if any.
    func incomingNotify(event: NotifyEvent?, dtmfValue: String?) {
        print("incomingNotify")
        // TODO: Handle incoming notifications
    }
}
