//
//  DeviceTableViewCell.swift
//  CoreBluetoothMaster
//
//  Created by David Nemec on 10/11/2017.
//  Copyright © 2017 Quanti. All rights reserved.
//

import UIKit
import SnapKit

class DeviceTableViewCell: UITableViewCell {
    
    var nameLabel = UILabel()
    var uuidLabel = UILabel()
    var infoLabel = UILabel()
    var flagLabel = UILabel()
    var statusLabel = UILabel()
    
    var entry: Device? {
        didSet {
            self.nameLabel.text = entry?.name ?? "No name"
            self.uuidLabel.text = entry?.identifier
            self.infoLabel.text = "RSSI: \(entry?.rssi ?? 999) (\(entry?.lastScanDate?.toFullDateTimeString() ?? ""))"
            self.flagLabel.text = "Flags: \(entry?.flagString ?? "")"
            
            var statusText = ""
            if entry?.touchRequired ?? false, entry?.isInPairing ?? false {
                statusText = "Supports background, in pairing"
                self.statusLabel.textColor = .red
            } else if entry?.touchRequired ?? false {
                statusText = "Supports background"
                self.statusLabel.textColor = .darkGreen
            } else {
                statusText = "Only foreground"
                self.statusLabel.textColor = .gray
            }
            
            
            
            self.statusLabel.text = "Status: \(statusText)"
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
         commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit(){
        
        // Modify labels
        nameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        uuidLabel.font = UIFont.boldSystemFont(ofSize: 11)
        
        // Create Stack View
        let mainStackView = UIStackView(arrangedSubviews: [nameLabel, uuidLabel, infoLabel, flagLabel, statusLabel])
        mainStackView.axis = .vertical
        mainStackView.alignment = .fill
        mainStackView.distribution = .fill

        self.contentView.addSubview(mainStackView)
        mainStackView.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview().offset(8)
            make.right.bottom.equalToSuperview().offset(-8)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
