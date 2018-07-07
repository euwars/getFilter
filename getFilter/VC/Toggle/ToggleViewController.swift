//
//  AIToggleViewController.swift
//  getFilter
//
//  Created by Farzad Nazifi on 6/22/18.
//  Copyright © 2018 Farzad Nazifi. All rights reserved.
//

import UIKit

class ToggleViewController: UIViewController {
    required init?(coder aDecoder: NSCoder) { fatalError("...") }
    
    enum ToggleMode {
        case ml
        case cs
    }
    
    let toggleMode: ToggleMode
    
    @IBOutlet var toggle: UISwitch!
    @IBOutlet var tileLabel: UILabel!
    @IBOutlet var detailLabel: UILabel!
    @IBOutlet var toggleView: ToggleView!
    @IBOutlet var imageView: UIImageView!
    
    init(toggleMode: ToggleMode) {
        self.toggleMode = toggleMode
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch toggleMode {
        case .ml:
            tileLabel.text = "Machine Learning"
            detailLabel.text = "Auto-detect incoming spam messages."
            imageView.image = UIImage(named: "ML")
            imageView.tintColor = #colorLiteral(red: 0.06527299434, green: 0.4328274429, blue: 0.8878107667, alpha: 1)
            toggle.thumbTintColor = #colorLiteral(red: 0.06527299434, green: 0.4328274429, blue: 0.8878107667, alpha: 1)
        case .cs:
            tileLabel.text = "CrowdSourcing"
            detailLabel.text = "Auto-block incoming phone calls."
            imageView.image = UIImage(named: "CS")
            imageView.tintColor = #colorLiteral(red: 0.9308083057, green: 0.3012276292, blue: 0.1826913357, alpha: 1)
            toggle.thumbTintColor = #colorLiteral(red: 0.9308083057, green: 0.3012276292, blue: 0.1826913357, alpha: 1)
        }
    }
    
    @IBAction func valueChanged(_ sender: UISwitch) {
    }
}

class ToggleView: UIView {
    let topCorner = CAShapeLayer()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 12, height: 12))
        topCorner.path = path.cgPath
        self.layer.mask = topCorner
    }
}

