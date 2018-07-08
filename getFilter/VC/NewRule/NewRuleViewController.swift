//
//  NewRuleViewController.swift
//  getFilter
//
//  Created by Farzad Nazifi on 7/8/18.
//  Copyright © 2018 Farzad Nazifi. All rights reserved.
//

import UIKit

class NewRuleViewController: UIViewController {
    required init?(coder aDecoder: NSCoder) { fatalError("...") }
    init() { super.init(nibName: nil, bundle: nil) }
    
    @IBOutlet var textField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder!, attributes: [NSAttributedString.Key.foregroundColor : UIColor.white.withAlphaComponent(0.4)])
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func cancelTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
}

class SelectiveView: UIView {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel?
    @IBOutlet var detailLabel: UILabel?
    
    @IBInspectable public var isSelected: Bool = false {
        didSet {
            update()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        update()
    }

    func update() {
        if !isSelected {
            let disabledColor = #colorLiteral(red: 0.2705882353, green: 0.2705882353, blue: 0.2901960784, alpha: 1)
            layer.borderColor = UIColor.clear.cgColor
            layer.borderWidth = 0
            imageView?.tintColor = disabledColor
            titleLabel?.textColor = disabledColor
            detailLabel?.textColor = disabledColor
        }else{
            titleLabel?.textColor = .white
            detailLabel?.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.4)
            layer.borderWidth = 1
            switch titleLabel?.text! {
            case "Phone", "Text":
                layer.borderColor = #colorLiteral(red: 0.09019607843, green: 0.4745098039, blue: 0.9176470588, alpha: 1).cgColor
                imageView.tintColor = #colorLiteral(red: 0.09019607843, green: 0.4745098039, blue: 0.9176470588, alpha: 1)
            case "Allow":
                layer.borderColor = #colorLiteral(red: 0, green: 0.8157687783, blue: 0.1033710912, alpha: 1).cgColor
                imageView.tintColor = #colorLiteral(red: 0, green: 0.8157687783, blue: 0.1033710912, alpha: 1)
            case "Block":
                layer.borderColor = #colorLiteral(red: 0.9146965146, green: 0.3095251918, blue: 0.2168177068, alpha: 1).cgColor
                imageView.tintColor = #colorLiteral(red: 0.9146965146, green: 0.3095251918, blue: 0.2168177068, alpha: 1)
            default: break;
            }
        }
    }
}
