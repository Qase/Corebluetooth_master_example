//
//  BluetoothStatusView.swift
//  CoreBluetoothMaster
//
//  Created by David Nemec on 06/03/2018.
//  Copyright © 2018 Quanti. All rights reserved.
//

import UIKit

class BluetoothStatusView: UIView {

    var bluetoothLabel = UILabel()
    let killSwitch = UISwitch.make(isOn: UserDefaults.standard.bool(forKey: Constants.UserDefaults.killIdentifier))
    let killLabel = UILabel.make(text: "Kill: ", textAlignment: .right)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createBottomView()
    }
    
    func createBottomView(){
        self.backgroundColor = .lightGray
        let bottomStackView = UIStackView()
        
        // Create ble label
        let bleStaticLabel = UILabel.make(text: "BLE Status:", font: UIFont.boldSystemFont(ofSize: 16))
        bleStaticLabel.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: UILayoutConstraintAxis.horizontal)

        //Create ble stack view
        let bleStackView = UIStackView.make(alignment: .center, axis: .horizontal, distribution: .fill)
        bleStackView.addArrangedSubviews([bleStaticLabel, bluetoothLabel, killLabel, killSwitch])

        // Create bottomStackView
        self.addSubview(bottomStackView)
        bottomStackView.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.right.equalToSuperview().offset(-8)
            make.left.equalToSuperview().offset(8)
        }
        bottomStackView.addArrangedSubview(bleStackView)
        
        //Create kill label
        self.killLabel.setContentHuggingPriority(UILayoutPriority.defaultLow, for: .horizontal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
