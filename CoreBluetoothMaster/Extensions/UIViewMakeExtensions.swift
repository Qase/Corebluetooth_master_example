//
//  UILabelExtension.swift
//  CoreBluetoothMaster
//
//  Created by David Nemec on 06/03/2018.
//  Copyright © 2018 Quanti. All rights reserved.
//

import UIKit

extension UILabel {
    static func make(text: String = "", textAlignment: NSTextAlignment = .left, font: UIFont? = nil) -> UILabel {
        let ret = UILabel()
        ret.text = text
        ret.textAlignment = textAlignment
        if let font = font {
            ret.font = font
        }
        return ret
    }
}

extension UISwitch {
    static func make(isOn: Bool = false) -> UISwitch {
        let ret = UISwitch()
        ret.isOn = isOn
        return ret
    }
}

extension UIStackView {
    static func make(alignment: UIStackViewAlignment? = nil, axis: UILayoutConstraintAxis? = nil, distribution: UIStackViewDistribution? = nil ) -> UIStackView {
        let ret = UIStackView()
        ret.alignment = alignment ?? ret.alignment
        ret.axis = axis ?? ret.axis
        ret.distribution = distribution ?? ret.distribution
        return ret
    }
    
    func addArrangedSubviews(_ views:[UIView]) {
        views.forEach { (view) in
            self.addArrangedSubview(view)
        }
    }
}
