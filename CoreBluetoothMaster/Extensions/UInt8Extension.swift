//
//  UInt8Extension.swift
//  CoreBluetoothMaster
//
//  Created by David Nemec on 02/03/2018.
//  Copyright © 2018 Quanti. All rights reserved.
//

import Foundation

extension UInt8 {
    
    func bitSet(nth: Int) -> Bool {
        return (self & (0b00000001 << nth)) > 0
    }
}
