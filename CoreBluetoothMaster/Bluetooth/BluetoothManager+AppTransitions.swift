//
//  BLuetoothManager+AppTransitions.swift
//  CoreBluetoothMaster
//
//  Created by David Nemec on 06/03/2018.
//  Copyright © 2018 Quanti. All rights reserved.
//

import UIKit
import CoreBluetooth
import QuantiLogger

// App transition handling
extension BluetoothManager {
    func registerNotifications()
    {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(applicationDidEnterBackground), name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
        notificationCenter.addObserver(self, selector: #selector(applicationWillEnterForeground), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    func requestBackgroundConnections(){
        let touchDevices =  devices.filter { (deviceManager) -> Bool in
            deviceManager.device.touchRequired
        }
        
        QLog("BluetoothManager Requesting connection to \(touchDevices.count) devices", onLevel: .info)
        touchDevices.forEach { (deviceManager) in
            deviceManager.connectToPeripheral(centralManager: centralManager, onBackground: true)
        }
    }
    
    func stopBackgroundConnections() {
        QLog("BluetoothManager Cancel connection to all devices", onLevel: .info)
        devices.forEach { (deviceManager) in
            centralManager.cancelPeripheralConnection(deviceManager.peripheral)
        }
    }
    
    @objc func applicationWillEnterForeground() {
        //type(of: self).applicationIsInBackground = false
        startScanner()
        //stopBackgroundConnections()
    }
    
    @objc func applicationDidEnterBackground() {
        //type(of: self).applicationIsInBackground = true
        stopScanner()
        requestBackgroundConnections()
    }
    
    
}
