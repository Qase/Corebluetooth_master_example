//
//  DeviceManager.swift
//  NNLockLite
//
//  Created by David Nemec on 09/11/2017.
//  Copyright © 2017 Quanti. All rights reserved.
//

import UIKit
import CoreBluetooth
import QuantiLogger
import UserNotifications

public class DeviceManager: NSObject, CBPeripheralDelegate {
    public let device: Device
    public let peripheral: CBPeripheral
    
    public var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    public var connectTask: DispatchWorkItem?
    
    
    init(peripheral: CBPeripheral) {
        self.peripheral = peripheral
        
        
        if let device = CoreDataStack.shared.deviceWith(uuidString: peripheral.identifier.uuidString) {
            self.device = device
        }
        else {
            self.device = Device(context: CoreDataStack.shared.persistentContainerContext)
        }
        
        super.init()
        self.device.identifier = peripheral.identifier.uuidString
        self.peripheral.delegate = self
    }
    
    init(peripheral: CBPeripheral, device: Device) {
        self.peripheral = peripheral
        self.device = device
        super.init()
        self.peripheral.delegate = self
    }
    
    func connectedToPeripheral(centralManager: CBCentralManager)
    {
        QLog("DeviceManager (\(device.name ?? "")) connectedToPeripheral ", onLevel: .info)

        // Post notification about sucesfull connection
        NotificationService.shared.presentNotificationWith(text: "Connected To \(device.name ?? "")")

        //disconnectFromPeripheral(centralManager: centralManager)
    }
    
    func disconectedFromPeripheral(centralManager: CBCentralManager)
    {
        QLog("DeviceManager (\(device.name ?? "")) disconnectedFromPeripheral", onLevel: .info)
        
        NotificationService.shared.presentNotificationWith(text: "Disconnected from \(device.name ?? "")")

        //Recreate connection request in lock was disconnected (only on background)
//        let shouldReconnectAfterDisconection = device.touchRequired && (BluetoothManager.applicationIsInBackground)
//        guard shouldReconnectAfterDisconection else {
//            QLog("DeviceManager (\(device.name ?? "")) no not reconnect", onLevel: .info)
//            return
//        }
        
        //Create background task just in case we would not manage to request connection before application dies
        cancelBackgroundTask()
        backgroundTask = UIApplication.shared.beginBackgroundTask (expirationHandler: {
            QLog("DeviceManager (\(self.device.name ?? "")) expirationHandler", onLevel: .debug)
            UIApplication.shared.endBackgroundTask(self.backgroundTask)
        })

        // Dispatch new connection after 5, because otherwise we would connect multiple times during one click
//        QLog("DeviceManager (\(device.name ?? "")) request new connect after 5 sec", onLevel: .info)
//        self.connectTask?.cancel()
//        let connectTask = DispatchWorkItem {
//            self.connectToPeripheral(centralManager: centralManager, onBackground: UIApplication.shared.applicationState == .background)
//        }
//        self.connectTask = connectTask
//        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: connectTask)
        
        // Well maybe try to connect immediately
        QLog("DeviceManager (\(device.name ?? "")) request new connect", onLevel: .info)
        if device.isInPairing {
                QLog("DeviceManager (\(device.name ?? "")) device is in pairing", onLevel: .warn)
        }
        
        self.connectToPeripheral(centralManager: centralManager, onBackground: BluetoothManager.applicationIsInBackground)
        
    }
    
    func connectToPeripheral(centralManager: CBCentralManager, onBackground: Bool = false) {
        
        // Discard background connect requests, that are not for Devices in touch mode
        if !device.touchRequired {
            QLog("DeviceManager (\(device.name ?? "")) connectToPeripheral NOT performed onBackground \(onBackground)", onLevel: .info)
            cancelBackgroundTask()
            return
        }
        
        // Request connect to device
        QLog("DeviceManager (\(device.name ?? "")) connectToPeripheral onBackground: \(onBackground) peripheralUUID: \(self.peripheral.identifier.uuidString)", onLevel: .info)
        centralManager.connect(peripheral, options: nil)
        QLog("DeviceManager (\(device.name ?? "")) connectToPeripheral after", onLevel: .info)
        
        // We requested bluetooth connection, so we can end background task (if created).
        cancelBackgroundTask()
    }
    
    func disconnectFromPeripheral(centralManager: CBCentralManager) {
        QLog("DeviceManager (\(device.name ?? "")) disconnectFromPeripheral", onLevel: .info)
        centralManager.cancelPeripheralConnection(peripheral)
    }
    
    func cancelBackgroundTask() {
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = UIBackgroundTaskInvalid
    }
    
}
