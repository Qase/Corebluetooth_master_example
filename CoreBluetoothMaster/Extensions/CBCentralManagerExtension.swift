//
//  CBCentralManagerExtension.swift
//  CoreBluetoothMaster
//
//  Created by David Nemec on 02/03/2018.
//  Copyright © 2018 Quanti. All rights reserved.
//

import Foundation
import CoreBluetooth

extension CBCentralManager {
    func retreiveAllPeripherals(withIdentifiers identifiers: [UUID], orServices services: [CBUUID]) -> [CBPeripheral] {
        var peripherals = self.retrievePeripherals(withIdentifiers: identifiers)
        let connectedPeripherals = self.retrieveConnectedPeripherals(withServices: services)
        peripherals.append(contentsOf: connectedPeripherals)
        return peripherals
    }
}

extension CBManagerState {
    var text: String {
        switch self {
        case .poweredOff:
            return "Powered Off"
        case .poweredOn:
            return "Powered On"
        case .resetting:
            return "Resetting"
        case .unauthorized:
            return "Unauthorized"
        case .unknown:
            return "Unknown"
        case .unsupported:
            return "Unsupported"
        }
    }
}
