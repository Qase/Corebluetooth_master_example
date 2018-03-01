//
//  Devices.swift
//  CoreBluetoothMaster
//
//  Created by David Nemec on 09/11/2017.
//  Copyright © 2017 Quanti. All rights reserved.
//

import UIKit
import CoreData

@objc(Device) public class Device: NSManagedObject {
//    public var RSSI: Int = -1000
//    
//    public var touchRequired: Bool = false
//    public var touchActive: Bool = false
//    public var tapRequired: Bool = false
//    public var isInPairing: Bool = false
//    public var identifier: String = ""
//
//
//    public var distanceTreshold = -100
//    public var configurationCounter: UInt16 = 0
//    public var lastScanDate: Date?
    
    var flagString: String {
        var string = ""
        if isSimulator {
            string += "isSimulator|"
        }
        if touchRequired {
            string += "touchRequired|"
        }
        if tapRequired {
            string += "tapRequired|"
        }
        if touchActive {
            string += "touchActive|"
        }
        if isInPairing {
            string += "isInPairing"
        }
        
        return string
    }
    
    static func orderedFetchRequest() -> NSFetchRequest<Device> {
        let fetchRequest: NSFetchRequest<Device> = Device.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true), NSSortDescriptor(key: "identifier", ascending: true)]
        return fetchRequest
    }
    
    public var identifierUUID: UUID? {
        guard let identifier = self.identifier else {
            return nil
        }
        return UUID(uuidString: identifier)
    }
    
    func updateFrom(_ advertisementData: Data?, rssi:NSNumber = 0) {
        
        lastScanDate = Date()
        guard let advertisementData = advertisementData, advertisementData.count >= 6 else {
            isSimulator = true
            touchRequired = true
            return
        }
        
        var distanceByte: UInt8 = 0
        (advertisementData as NSData).getBytes(&distanceByte, range: NSRange(location: 2, length: 1))
        distanceTreshold = (Int32(-30 + (Int(distanceByte & 0x1F) * -3)))
        self.rssi = Int32(truncating: rssi)
        
        var flagsByte: UInt8 = 0
        (advertisementData as NSData).getBytes(&flagsByte, range: NSRange(location: 3, length: 1))
        touchRequired = (flagsByte & 0b00000001) > 0
        touchActive = (flagsByte & 0b00000010) > 0
        tapRequired = (flagsByte & 0b00000100) > 0
        isInPairing = (flagsByte & 0b00001000) > 0
        
        var counterBytes: UInt16 = 0
        (advertisementData as NSData).getBytes(&counterBytes, range: NSRange(location: 4, length: 2))
        configurationCounter = Int32(CFSwapInt16(counterBytes))
        

        
    }
}

