//
//  BluetoothManager.swift
//  CoreBluetoothMaster
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
    
    public var centralManager: CBCentralManager!
    public var delegate: BluetoothManagerDelegate?
    
    var devices: [DeviceManager] = []
    
    var servicesArray = [CBUUID(string: Constants.Bluetooth.Identifiers.ServiceUUID), CBUUID(string: Constants.Bluetooth.Identifiers.ServiceUUIDSecondary)]
    
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
    
    func restoreDevices(restoredPeripherals: [CBPeripheral] = [] ) {
        let devices = CoreDataStack.shared.getAllDevices()
        let deviceUUIDs = devices.map { (device) -> UUID? in
            return device.identifierUUID
        }.flatMap { $0 }

        var peripherals = centralManager.retreiveAllPeripherals(withIdentifiers: deviceUUIDs, orServices: servicesArray)
        peripherals.append(contentsOf: restoredPeripherals)
        peripherals = Array(Set(peripherals))

        QLog("restoreDevices Devices: \(devices)", onLevel: .info)
        QLog("restoreDevices Device UUIDs: \(deviceUUIDs)", onLevel: .info)
        QLog("restoreDevices peripherals: \(peripherals)", onLevel: .info)
        QLog("restoreDevices restoredPeripherals: \(restoredPeripherals)", onLevel: .info)

        self.devices = devices.flatMap { (device) -> DeviceManager? in
            let peripheralO = peripherals.first(where: { (peripheral) -> Bool in
                peripheral.identifier == device.identifierUUID && device.identifierUUID != nil
            })
            guard let peripheral = peripheralO  else {
                QLog("UBER ERROR: System forgot peripheral \(device.name ?? "no-name") \(device.identifierUUID?.uuidString ?? "nil")", onLevel: .error)
                return nil
            }
            return DeviceManager(peripheral: peripheral, device: device)
        }
    }
}
