//
//  RootNavigationViewController.swift
//  getFilter
//
//  Created by Farzad Nazifi on 6/13/18.
//  Copyright © 2018 Farzad Nazifi. All rights reserved.
//

import UIKit

class RootNavigationViewController: UINavigationController {
    required init?(coder aDecoder: NSCoder) { fatalError("...") }
    init() { super.init(nibName: nil, bundle: nil) }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isNavigationBarHidden = true
        viewControllers = [HomeFlowViewController()]
    }
}
