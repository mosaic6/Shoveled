//
//  AppDelegate.swift
//  Shoveled
//
//  Created by Joshua Walsh on 9/19/15.
//  Copyright © 2015 Lucky Penguin. All rights reserved.
//

import UIKit
import CoreData
import Fabric
import Crashlytics
import Firebase
import FirebaseDatabase
import FirebaseMessaging
import UserNotifications
import FirebaseInstanceID
import Stripe
import SendGrid

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var config = Configuration()

    override init() {
        super.init()

        var config = Configuration()
        let fileopts = FirebaseOptions.init(contentsOfFile: config.environment.baseURL)
        if let fileopts = fileopts {
            FirebaseApp.configure(options: fileopts)
            Database.database().isPersistenceEnabled = true
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        guard let initialViewController = storyboard.instantiateViewController(withIdentifier: "CurrentStatusViewController") as? CurrentStatusViewController else {
            return false
        }

        let navController: UINavigationController = UINavigationController(rootViewController: initialViewController)

        self.window?.rootViewController = navController
        self.window?.makeKeyAndVisible()

        Fabric.with([Crashlytics.self, STPAPIClient.self])

        Stripe.setDefaultPublishableKey(config.environment.stripeKey)
        self.registerSendgridAuth()

        return true
    }

    func registerSendgridAuth() {
        let myApiKey = "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"
        Session.shared.authentication = Authentication.apiKey(myApiKey)
    }

    // MARK: Register for push
    func registerForPushNotifications(_ application: UIApplication) {
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

    func tokenRefreshNotification(notification: NSNotification) {
        InstanceID.instanceID().token()
        connectToFcm()
    }

    func connectToFcm() {
        Messaging.messaging().shouldEstablishDirectChannel = true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
        connectToFcm()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        Messaging.messaging().shouldEstablishDirectChannel = false
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        var token: String = ""
        for i in 0..<deviceToken.count {
            token += String(format: "%02.2hhx", deviceToken[i] as CVarArg)
        }

        Messaging.messaging().setAPNSToken(deviceToken, type: .sandbox)
        print("Device Token:", token)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        if error._code == 3010 {
            print("Push notifications are not supported in the iOS Simulator.")
        } else {
            print("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
    }

    func application(_ application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
        return true
    }

    func application(_ application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
        return true
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping(UIBackgroundFetchResult) -> Void) {

        print("Message ID: \(String(describing: userInfo["gcm.message_id"]))")
        print("%@", userInfo)
    }
}

// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {

    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        // Print message ID.
        print("Message ID: \(userInfo["gcm.message_id"]!)")

        // Print full message.
        print("%@", userInfo)
    }
}

extension AppDelegate : MessagingDelegate {
    // Receive data message on iOS 10 devices.
    func application(received remoteMessage: MessagingRemoteMessage) {
        print("%@", remoteMessage.appData)
    }

    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        // Let FCM know about the message for analytics etc.
        Messaging.messaging().appDidReceiveMessage(userInfo)
        // handle your message
    }
}
