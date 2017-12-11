//
//  BluetoothManager.swift
//  NNLockLite
//
//  Created by David Nemec on 09/11/2017.
//  Copyright © 2017 Quanti. All rights reserved.
//

import UIKit
import CoreBluetooth
import QuantiLogger


public protocol BluetoothManagerDelegate: class {
    func scanManagerDidUpdateState(_ manager: BluetoothManager)
}

public class BluetoothManager: NSObject {
    
    fileprivate var centralManager: CBCentralManager!
    public var delegate: BluetoothManagerDelegate?
    
    var devices: [DeviceManager] = []
    
    static var applicationIsInBackground: Bool {
        return UIApplication.shared.applicationState == .background
    }
    
    public override init()
    {
        QLog("BluetoothManager init", onLevel: .info)
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionRestoreIdentifierKey: Constants.Bluetooth.Identifiers.RestoreIdentifierKey])
        registerNotifications()
        restoreDevices()
    }
    
    func restoreDevices(){
        let devices = CoreDataStack.shared.getAllDevices()
        let deviceUUIDs = devices.map { (device) -> UUID? in
            return device.identifierUUID
        }.flatMap { $0 }
        
        let peripherals = centralManager.retrievePeripherals(withIdentifiers: deviceUUIDs)
        
        let deviceManagers =  devices.map { (device) -> DeviceManager? in
            if let peripheral = peripherals.first(where: { (peripheral) -> Bool in
                peripheral.identifier == device.identifierUUID && device.identifierUUID != nil
            }) {
                return DeviceManager(peripheral: peripheral, device: device)
            }
            QLog("UBER ERROR: System forgot peripheral", onLevel: .error)
            return nil
        }
        
        self.devices = deviceManagers.flatMap { $0 }
    }
}


// CentralManagerDelegate handling
extension BluetoothManager: CBCentralManagerDelegate {
    
    private func centralManagerWentPoweredOn(){
        if type(of: self).applicationIsInBackground {
            requestBackgroundConnections()
        }
        else {
            startScanner()
        }
    }
    
    private func centralManagerWentPoweredOff(){
        NotificationService.shared.presentNotificationWith(text: "WARNING: Bluetooth is powered off")
    }
    
    private func startScanner(){
        if centralManager.isScanning {
            return
        }
        QLog("BluetoothManager: Starting scanner", onLevel: .info)
        centralManager.scanForPeripherals(withServices: [CBUUID(string: Constants.Bluetooth.Identifiers.ServiceUUID)], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
    }
    
    private func stopScanner(){
        if !centralManager.isScanning {
            return
        }
        QLog("BluetoothManager: Stopping scanner", onLevel: .info)
        centralManager.stopScan()
    }
    
    private func deviceManagerFor(_ peripheral: CBPeripheral) -> DeviceManager
    {
        if let device = devices.first(where: { (deviceManager) -> Bool in deviceManager.device.identifierUUID == peripheral.identifier }){
            return device
        }
        
        // Create Device Manager if needed
        let newDeviceManager = DeviceManager(peripheral: peripheral)
        devices.append(newDeviceManager)
        return newDeviceManager
    }
    
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        //QLog("ScanManager centralManagerdidDiscover \(peripheralName) data: \(advertisementData) rssi: \(RSSI)", onLevel: .info)
        let peripheralName = peripheral.name ?? "no-name"
        let deviceManager = self.deviceManagerFor(peripheral)
        deviceManager.device.updateFrom(advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data, rssi: RSSI)
        deviceManager.device.name = peripheralName
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        guard let deviceManager = devices.first(where: { (deviceManager) -> Bool in deviceManager.device.identifierUUID == peripheral.identifier }) else {
            QLog("BluetoothManager didConnect to Unknown device", onLevel: .error)
            centralManager.cancelPeripheralConnection(peripheral)
            return
        }
        deviceManager.connectedToPeripheral(centralManager: centralManager)
    }
    
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        NotificationService.shared.presentNotificationWith(text: "didFailToConnect")
        guard let deviceManager = devices.first(where: { (deviceManager) -> Bool in deviceManager.device.identifierUUID == peripheral.identifier }) else {
            QLog("BluetoothManager didFailToConnect to Unknown device", onLevel: .error)
            return
        }

        QLog("BluetoothManager didFailToConnect to \(deviceManager.device.name ?? "")", onLevel: .error)
        deviceManager.connectToPeripheral(centralManager: centralManager)
        
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        guard let deviceManager = devices.first(where: { (deviceManager) -> Bool in deviceManager.device.identifierUUID == peripheral.identifier }) else {
            QLog("BluetoothManager didDisconnect to Unknown device", onLevel: .error)
            NotificationService.shared.presentNotificationWith(text: "Disconnected From Unknown")
            return
        }
        deviceManager.disconectedFromPeripheral(centralManager: centralManager)
    }
    
    public var centralState:CBManagerState {
        return centralManager.state
    }
    
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        QLog("BluetoothManager centralManagerDidUpdateState", onLevel: .info)
        switch central.state {
        case .poweredOff:
            QLog("BLE status: Powered Off", onLevel: .info)
            centralManagerWentPoweredOff()
        case .poweredOn:
            QLog("BLE status: Powered On (background:\(type(of: self).applicationIsInBackground))", onLevel: .info)
            centralManagerWentPoweredOn()
        case .resetting: QLog("BLE status: Resetting", onLevel: .info)
        case .unauthorized: QLog("BLE status: Unauthorized", onLevel: .info)
        case .unknown: QLog("BLE status: Unknown", onLevel: .info)
        case .unsupported: QLog("BLE status: Unsupported", onLevel: .info)
        }
        delegate?.scanManagerDidUpdateState(self)
    }
    
    public func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        QLog("BluetoothManager centralManager willRestoreState", onLevel: .info)
        restoreDevices()
        //requestBackgroundConnections()
    }
}

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
