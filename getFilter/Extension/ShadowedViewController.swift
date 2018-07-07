//
//  ShadowedViewController.swift
//  getFilter
//
//  Created by Farzad Nazifi on 6/22/18.
//  Copyright © 2018 Farzad Nazifi. All rights reserved.
//

import UIKit

class ShadowedViewController: UIViewController {
    private var shadowLayer = CAShapeLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.insertSublayer(shadowLayer, at: 0)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        shadowLayer.path = UIBezierPath(roundedRect: view.frame, cornerRadius: 12).cgPath
        shadowLayer.fillColor = UIColor.white.cgColor
        
        shadowLayer.shadowColor = UIColor.black.cgColor
        shadowLayer.shadowPath = shadowLayer.path
        shadowLayer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        shadowLayer.shadowOpacity = 0.1
        shadowLayer.shadowRadius = 5
    }
}
