//
//  SwiftSampleApp.swift
//  SwiftSample
//
//  Created by Melvin Salas on 23/10/23.
//

import SwiftUI
import BandwidthSDK
import FirebaseCore
import FirebaseMessaging
import FirebaseFirestore
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        // Request permission for notifications
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notification permissions: \(error.localizedDescription)")
            }
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        }
        
        Messaging.messaging().delegate = self
        // Handle app launch from notification
        if let notification = launchOptions?[.remoteNotification] as? [String: AnyObject] {
            handleIncomingCallNotification(userInfo: notification) // ✅ Handle notification
        }
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        print("APNs Token: \(deviceToken.map { String(format: "%02.2hhx", $0) }.joined())")
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        if let fcm = Messaging.messaging().fcmToken {
            print("fcm", fcm)
        }
    }
    
    // Foreground notification handling
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let userInfo = notification.request.content.userInfo
        handleIncomingCallNotification(userInfo: userInfo) // ✅ Handle notification
        completionHandler([.badge, .sound, .banner]) // Show banner
    }
    
    // Background notification handling
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        // Handle notification click
        let userInfo = response.notification.request.content.userInfo
        handleIncomingCallNotification(userInfo: userInfo) // ✅ Handle notification
        completionHandler()
    }
    
    // Function to extract payload and notify SwiftUI
    private func handleIncomingCallNotification(userInfo: [AnyHashable: Any]) {
        guard let accountId = userInfo["accountId"] as? String,
              let applicationId = userInfo["applicationId"] as? String,
              let fromNo = userInfo["fromNo"] as? String,
              let toNo = userInfo["toNo"] as? String else {
            print("Invalid notification payload")
            return
        }
        
        let callData: [String: String] = [
            "accountId": accountId,
            "applicationId": applicationId,
            "fromNo": fromNo,
            "toNo": toNo
        ]
        
        // Post notification to SwiftUI to open ringing screen
        NotificationCenter.default.post(name: NSNotification.Name("IncomingCall"), object: nil, userInfo: callData)
    }
}

@main
struct SwiftSampleApp: App {
    @State private var phoneNumber = ""
    @State private var isMuted = false
    @State private var isHolded = false
    @State private var session: BandwidthSession? = nil
    @State private var callState: CallState = .null
    @State private var resultFromRingingScreen: String = ""
    @State private var isSecondViewActive: Bool = false
    @StateObject var notificationManager = NotificationManager()
    private let bandwidthUA = BandwidthUA()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            Group(){
                if(isSecondViewActive){
                    RingingView(result: $resultFromRingingScreen, number: $phoneNumber)
                }else{
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
            }.task {
                await notificationManager.request()
                updateStatus(merge: false)
            }.onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("IncomingCall"))) { notification in
                if let userInfo = notification.userInfo as? [String: String] {
                    print("[SwiftSample] Incoming Call from \(userInfo["fromNo"] ?? "Unknown")")
                    phoneNumber = (userInfo["fromNo"] ?? "Unknown").replacingOccurrences(of: "+", with: "")
                    isSecondViewActive = true
                }
            }.onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("AcceptCall"))) { notification in
                print("[SwiftSample] Accept Call from \($phoneNumber)")
                isSecondViewActive = false
                makeCall()
            }.onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("DeclinedCall"))) { notification in
                print("[SwiftSample] Declined Call from \($phoneNumber)")
                phoneNumber = ""
                isSecondViewActive = false
            }
        }
    }
    
    init(){
        configureBandwidthUA()
    }
    
    func updateStatus(status: String = "Idle",merge: Bool = true) {
        guard FirebaseApp.app() != nil else {
            print("Firebase is not initialized yet!")
            return
        }
        
        let db = Firestore.firestore()
        
        // Reference to Firestore document at /agents/{phoneNumber}
        let agentRef = db.collection("agents").document(extractStringValue(forKey: .accountUsername))
        let deviceName = UIDevice.current.model
        // JSON Data to be updated
        let data: [String: Any] = [
            "status": status,
            "token": notificationManager.getFCMToken() ?? "",
            "device":deviceName
        ]
        
        // Update Firestore document
        agentRef.setData(data, merge: merge) { error in
            if let error = error {
                print("Error updating FCM token: \(error.localizedDescription)")
            } else {
                print("FCM token successfully updated for \(extractStringValue(forKey: .accountUsername))")
            }
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
        if let authTokenResponse = getOAuthTokenFromURL(extractStringValue(forKey: .connectionToken),
                                                        headerUser: extractStringValue(forKey: .connectionHeaderUser),
                                                        headerPass: extractStringValue(forKey: .connectionHeaderPass)) {
            let formatPhoneNumber = "+" + phoneNumber
            session = bandwidthUA.makeCall(formatPhoneNumber,
                                           domain: extractStringValue(forKey: .connectionDomain),
                                           authToken: authTokenResponse.access_token)
            if let session = session {
                session.addSessionEventListener(listener: self)
            } else {
                fatalError("Failed to create a session.")
            }
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
            try bandwidthUA.configureAccount(username: extractStringValue(forKey: .accountUsername),
                                             displayName: extractStringValue(forKey: .accountDisplayName),
                                             password: extractStringValue(forKey: .accountPassword),
                                             authName: extractStringValue(forKey: .accountUsername))
        } catch {
            // Handle the error here
            print("An error occurred: \(error)")
        }
    }
    
    private func getOAuthTokenFromURL(_ connectionUrl: String, headerUser: String?, headerPass: String?) -> AuthTokenResponse? {
        guard let url = URL(string: connectionUrl) else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        if let user = headerUser, let password = headerPass {
            let loginString = "\(user):\(password)"
            if let loginData = loginString.data(using: .utf8) {
                let base64LoginString = loginData.base64EncodedString()
                request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
                let bodyParameters = "grant_type=client_credentials"
                request.httpBody = bodyParameters.data(using: .utf8)
            }
        }
        
        var authTokenResponse: AuthTokenResponse? = nil
        let semaphore = DispatchSemaphore(value: 0)
        
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(AuthTokenResponse.self, from: data)
                    authTokenResponse = result
                } catch {
                    print(error.localizedDescription)
                }
            }
            semaphore.signal()
        }
        task.resume()
        
        semaphore.wait()
        return authTokenResponse
    }
}

extension SwiftSampleApp: BandwidthSessionEventListener {
    /// Called when a call is terminated.
    /// - Parameter session: The BandwidthSession object for the terminated call.
    func callTerminated(session: BandwidthSession?) {
        resetCallState()
        updateStatus(status: "Idle",merge: false)
        //bandwidthUA.logout()
    }
    
    /// Called when a call is in progress.
    /// - Parameter session: The BandwidthSession object for the ongoing call.
    func callProgress(session: BandwidthSession?) {
        if let session = session {
            callState = session.callState
            updateStatus(status: callState.description)
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

internal struct AuthTokenResponse: Codable {
    let access_token: String
}
