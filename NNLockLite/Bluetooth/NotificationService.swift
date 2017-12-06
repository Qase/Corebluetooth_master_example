//
//  NotificationService.swift
//  NNLockLite
//
//  Created by David Nemec on 06/12/2017.
//  Copyright © 2017 Quanti. All rights reserved.
//

import UIKit
import QuantiLogger
import UserNotifications

class NotificationService {
    static var shared = NotificationService()
    private init() {
        
    }
    
    func presentNotificationWith(text: String) {
        
        let notificationContent = UNMutableNotificationContent()
        notificationContent.badge = UIApplication.shared.applicationIconBadgeNumber + 1 as NSNumber
        notificationContent.title = text
        notificationContent.subtitle = "\(Date())"
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: notificationContent, trigger: nil) //"com.quanti.bluetooth.connect"
        
        UNUserNotificationCenter.current().add(request) { (error) in
            QLog("UNUserNotificationCenter add \(String(describing: error))", onLevel: .info)
        }
    }
}
