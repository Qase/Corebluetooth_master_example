//
//  BLuetoothManager+CentralManager.swift
//  CoreBluetoothMaster
//
//  Created by David Nemec on 06/03/2018.
//  Copyright © 2018 Quanti. All rights reserved.
//

import UIKit
import CoreBluetooth
import QuantiLogger

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
    
    public func startScanner(){
        if centralManager.isScanning {
            return
        }
        QLog("BluetoothManager: Starting scanner", onLevel: .info)
        centralManager.scanForPeripherals(withServices: servicesArray, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
    }
    
    public func stopScanner(){
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
        
        let peripheralName = peripheral.name ?? "no-name"
        
        QLog("ScanManager centralManagerdidDiscover \(peripheralName) data: \(advertisementData) rssi: \(RSSI)", onLevel: .info)
        
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
            centralManagerWentPoweredOff()
        case .poweredOn:
            centralManagerWentPoweredOn()
        default:
            ()
        }
        QLog("BLE status: \(central.state.text) (background:\(type(of: self).applicationIsInBackground))", onLevel: .info)
        delegate?.scanManagerDidUpdateState(self)
    }
    
    public func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        QLog("BluetoothManager centralManager willRestoreState \(dict)", onLevel: .info)
        
        let peripherals = dict[CBCentralManagerRestoredStatePeripheralsKey] as? [CBPeripheral]
        
        restoreDevices(restoredPeripherals: peripherals ?? [])
        //requestBackgroundConnections()
    }
}
