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

public class DeviceManager: NSObject, CBPeripheralDelegate {
    public let device: Device
    public let peripheral: CBPeripheral
    
    init(peripheral: CBPeripheral) {
        self.peripheral = peripheral
        self.device = Device(context: CoreDataStack.shared.persistentContainerContext)
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
    
    func connectedToPeripheral()
    {
        
    }
    
    func disconectedFromPeripheral()
    {
        
    }
    
    func connectToPeripheral(centralManager: CBCentralManager){
        QLog("connectToPeripheral \(device.name ?? "")", onLevel: .info)
        centralManager.connect(peripheral, options: nil)
    }
    
    func disconnectFromPeripheral(centralManager: CBCentralManager){
        QLog("disconnectFromPeripheral \(device.name ?? "")", onLevel: .info)
        centralManager.cancelPeripheralConnection(peripheral)
    }
    
}
