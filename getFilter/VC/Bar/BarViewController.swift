//
//  BarViewController.swift
//  getFilter
//
//  Created by Farzad Nazifi on 6/29/18.
//  Copyright © 2018 Farzad Nazifi. All rights reserved.
//

import UIKit

class BarViewController: UIViewController {
    required init?(coder aDecoder: NSCoder) { fatalError("...") }
    init() { super.init(nibName: nil, bundle: nil) }
    
    @IBAction func settingsTapped(_ sender: UIButton) {
        let settingsVC = SettingsViewController()
        present(settingsVC, animated: true, completion: nil)
    }
}
