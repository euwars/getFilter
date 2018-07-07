//
//  HomeFlowViewController.swift
//  getFilter
//
//  Created by Farzad Nazifi on 6/13/18.
//  Copyright © 2018 Farzad Nazifi. All rights reserved.
//

import UIKit

class HomeFlowViewController: UIViewController, RulesViewControllerDelegate {
    
    required init?(coder aDecoder: NSCoder) { fatalError("...") }
    init() { super.init(nibName: nil, bundle: nil) }
    
    @IBOutlet var barContainer: UIView!
    @IBOutlet var aiToggleContainer: UIView!
    @IBOutlet var socialToggleContainer: UIView!
    @IBOutlet var rulesContainer: UIView!
    @IBOutlet var rulesHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        transition(to: barContainer, duration: 0, child: BarViewController(), completion: nil)
        transition(to: aiToggleContainer, duration: 0, child: ToggleViewController(toggleMode: .ml), completion: nil)
        transition(to: socialToggleContainer, duration: 0, child: ToggleViewController(toggleMode: .cs), completion: nil)
        transition(to: rulesContainer, duration: 0, child: RulesViewController(delegate: self), completion: nil)
    }
    
    func updateHeight(const: CGFloat) {
        guard rulesHeightConstraint.constant != const else { return }
        rulesHeightConstraint.constant = const
        view.layoutIfNeeded()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
