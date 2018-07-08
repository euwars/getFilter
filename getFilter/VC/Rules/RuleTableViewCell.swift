//
//  RuleTableViewCell.swift
//  getFilter
//
//  Created by Farzad Nazifi on 6/23/18.
//  Copyright © 2018 Farzad Nazifi. All rights reserved.
//

import UIKit
import PhoneNumberKit

class RuleTableViewCell: UITableViewCell {
    
    @IBOutlet var ruleImageView: UIImageView!
    @IBOutlet var contentLabel: UILabel!
    @IBOutlet var contentTypeLabel: UILabel!
    
    func setData(rule: UserRule) {
        if let m = rule.m {
            contentLabel.text = m
            contentTypeLabel.text = "Text"
        }else if let n = rule.n {
            let phoneNumberKit = PhoneNumberKit()
            let phoneNumber = try! phoneNumberKit.parse(n)
            contentLabel.text = phoneNumberKit.format(phoneNumber, toType: .national)
            contentTypeLabel.text = "Number"
        }
        
        ruleImageView.image = rule.r == .a ? UIImage(named: "Allow") : UIImage(named: "Block")
        ruleImageView.tintColor = rule.r == .a ? #colorLiteral(red: 0, green: 0.8157687783, blue: 0.1033710912, alpha: 1) : #colorLiteral(red: 0.9146965146, green: 0.3095251918, blue: 0.2168177068, alpha: 1)
    }
}
