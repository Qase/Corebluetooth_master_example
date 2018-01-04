//
//  Constants.swift
//  NNLockLite
//
//  Created by David Nemec on 09/11/2017.
//  Copyright © 2017 Quanti. All rights reserved.
//

import UIKit

struct Constants {
    public struct Bluetooth {
        public struct Identifiers {
            public static let RestoreIdentifierKey = "2NCentralManager"
            public static let ServiceUUID = "a54e8025-b815-41ba-bf3f-cbf7d06de5b4"
            public static let ServiceUUIDSecondary = "62400EDB-ABA5-4FD0-84B2-C508620020B2"
        }
    }
    
    public struct UserDefaults {
        public static let killIdentifier = "killIdentifier"
    }
    
    public struct TableCells {
        public static let deviceCell = "deviceCell"
    }
}
