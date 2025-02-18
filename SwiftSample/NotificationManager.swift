//
//  NotificationManager.swift
//  SwiftSample
//
//  Created by User on 26/11/24.
//

import Foundation
import UserNotifications
import FirebaseMessaging

@MainActor
class NotificationManager: ObservableObject{
    @Published private(set) var hasPermission = false
    
    init() {
        Task{
            await getAuthStatus()
        }
    }
    
    func request() async{
        do {
            try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
            await getAuthStatus()
        } catch{
            print(error)
        }
    }
    
    func getAuthStatus() async {
        let status = await UNUserNotificationCenter.current().notificationSettings()
        switch status.authorizationStatus {
        case .authorized, .ephemeral, .provisional:
            hasPermission = true
        default:
            hasPermission = false
        }
    }
    
    func getFCMToken() -> String? {
        // Retrieve the FCM token from Firebase Messaging
        if let fcmToken = Messaging.messaging().fcmToken {
            return fcmToken
        }
        // Return nil if the FCM token is not available
        return nil
    }
}
