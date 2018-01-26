//
//  NotificationManager.swift
//  Shoveled
//
//  Created by Joshua Walsh on 11/19/16.
//  Copyright © 2016 Lucky Penguin. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseMessaging
import UserNotifications
import FirebaseInstanceID
import Messages

let userLocationNoticationKey = "com.mosaic6.userLocationKey"

class NotificationManager {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        var token: String = ""
        for i in 0..<deviceToken.count {
            token += String(format: "%02.2hhx", deviceToken[i] as CVarArg)
        }

        Messaging.messaging().setAPNSToken(deviceToken, type: .sandbox)
        print("Device Token:", token)
    }

    // MARK: Register for push
    class func registerForPushNotifications(_ application: UIApplication) {
        let viewAction = UIMutableUserNotificationAction()
        viewAction.identifier = "VIEW_IDENTIFIER"
        viewAction.title = "View"
        viewAction.activationMode = .foreground

        let newsCategory = UIMutableUserNotificationCategory()
        newsCategory.identifier = "NEWS_CATEGORY"
        newsCategory.setActions([viewAction], for: .default)

        let categories: Set <UIUserNotificationCategory> = [newsCategory]

        let notificationSettings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: categories)
        application.registerUserNotificationSettings(notificationSettings)
    }

    func setNotificationSettings(application: UIApplication) {
        // [START register_for_notifications]
        if #available(iOS 10.0, *) {
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })

            // For iOS 10 display notification (sent via APNS)
//            UNUserNotificationCenter.current().delegate = UIApplication.shared.

        } else {
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }

        // Add observer for InstanceID token refresh callback.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.tokenRefreshNotification),
                                               name: NSNotification.Name.InstanceIDTokenRefresh,
                                               object: nil)

        let notificationTypes: UIUserNotificationType = [.alert, .badge, .sound]
        let pushNotificationSettings = UIUserNotificationSettings(types: notificationTypes, categories: nil)
        application.registerUserNotificationSettings(pushNotificationSettings)
        application.registerForRemoteNotifications()
    }

    @objc func tokenRefreshNotification(notification: NSNotification) {
        guard let refreshedToken = InstanceID.instanceID().token() else { return }
        print("InstanceID token: \(refreshedToken)")

        connectToFcm()
    }

    func connectToFcm() {
        if Messaging.messaging().shouldEstablishDirectChannel {
            print("Connected to FCM")
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
        connectToFcm()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        if Messaging.messaging().shouldEstablishDirectChannel {
            print("Disconnected from FCM.")
        }
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        if error._code == 3010 {
            print("Push notifications are not supported in the iOS Simulator.")
        } else {
            print("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
    }
}
