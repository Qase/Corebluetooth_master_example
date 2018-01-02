//
//  AppDelegate.swift
//  NNLockLite
//
//  Created by David Nemec on 08/11/2017.
//  Copyright © 2017 Quanti. All rights reserved.
//

import UIKit
import QuantiLogger
import UserNotifications

extension Bundle {
    
    var appName: String {
        return infoDictionary?["CFBundleName"] as? String ?? "unknown"
    }
    
    var bundleId: String {
        return bundleIdentifier!
    }
    
    var versionNumber: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String  ?? "unknown"
    }
    
    var buildNumber: String {
        return infoDictionary?["CFBundleVersion"] as? String  ?? "unknown"
    }
    
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var timer: Timer?
    public var bluetoothManager:BluetoothManager!
    
    public static var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    public static func prepareLogger() {
        let systemLogger = SystemLogger(subsystem: "com.quanti.swift.NNLockLite", category: "logging")
        systemLogger.levels = [.verbose, .info, .debug, .warn, .error]

        let fileLogger = FileLogger()
        fileLogger.levels = [.verbose, .info, .debug, .warn, .error]

        LogManager.shared.add(systemLogger)
        LogManager.shared.add(fileLogger)
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        AppDelegate.prepareLogger()
        
//        QLog("AppDelegate didFinishLaunchingWithOptions", onLevel: .info)

        let systemVersion = UIDevice.current.systemVersion
        QLog("AppDelegate versionNumber:\(Bundle.main.versionNumber), buildNumber:\(Bundle.main.buildNumber) systemVersion: \(systemVersion)", onLevel: .info)
        
        if let centrals = launchOptions?[UIApplicationLaunchOptionsKey.bluetoothCentrals]{
            NotificationService.shared.presentNotificationWith(text: "App Launched - Restoring State")
            QLog("AppDelegate didFinishLaunchingWithOptions bluetoothCentrals \(centrals)", onLevel: .info)
        }
        else {
            NotificationService.shared.presentNotificationWith(text: "App Launched")
        }
        
        
        
        bluetoothManager = BluetoothManager()
        
        
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (_) in
            if UIApplication.shared.applicationState == .background {
                QLog("Timer keepAlive tick", onLevel: .info)
            }
        }
        
        // Draw controller
        window = UIWindow(frame: UIScreen.main.bounds)
        if let _window = window {
            let controller = ViewController()
            bluetoothManager.delegate = controller
            _window.rootViewController = BaseNavigationViewController(rootViewController: controller)
            _window.makeKeyAndVisible()
        }
        
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            // Enable or disable features based on authorization.
        }
        
        let textAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        UINavigationBar.appearance().titleTextAttributes = textAttributes

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
//        QLog("AppDelegate applicationWillResignActive", onLevel: .info)
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
//        QLog("AppDelegate applicationDidEnterBackground", onLevel: .info)
        CoreDataStack.shared.saveContext()
        
        
        if UserDefaults.standard.bool(forKey: Constants.UserDefaults.killIdentifier){
            DispatchQueue.main.async {
                kill(getpid(), SIGKILL);
            }
        }

        
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
//        QLog("AppDelegate applicationWillEnterForeground", onLevel: .info)
        UIApplication.shared.applicationIconBadgeNumber = 0
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
//        QLog("AppDelegate applicationDidBecomeActive", onLevel: .info)
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
//        QLog("AppDelegate applicationWillTerminate", onLevel: .info)
        CoreDataStack.shared.saveContext()
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        QLog("AppDelegate userNotificationCenter didReceive", onLevel: .info)
        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        QLog("AppDelegate userNotificationCenter willPresent", onLevel: .info)
        completionHandler([.alert, .badge, .sound])
    }
    
}

