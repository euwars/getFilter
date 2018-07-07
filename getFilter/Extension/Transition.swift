//
//  Transition.swift
//  Sentinel
//
//  Created by Farzad Nazifi on 01.06.18.
//  Copyright © 2018 Samourai. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func transition(to containerView: UIView? = nil, duration: Double = 0.25, child: UIViewController, completion: ((Bool) -> Void)? = nil) {
        
        let container = ((containerView != nil) ? containerView! : view!)
        
        let current = children.last
        addChild(child)
        
        let newView = child.view!
        newView.translatesAutoresizingMaskIntoConstraints = true
        newView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        newView.frame = container.bounds
        
        func add() {
            container.addSubview(newView)
            
            UIView.animate(withDuration: duration, delay: 0, options: [.transitionCrossDissolve], animations: { }, completion: { done in
                child.didMove(toParent: self)
                completion?(done)
            })
        }
        
        if let existing = current {
            if existing == child {
                existing.willMove(toParent: nil)
                
                transition(from: existing, to: child, duration: duration, options: [.transitionCrossDissolve], animations: { }, completion: { done in
                    existing.removeFromParent()
                    child.didMove(toParent: self)
                    completion?(done)
                })
            }else{
                add()
            }
        } else {
            add()
        }
    }
}


extension UISegmentedControl {
    func removeBorders(color: UIColor) {
        setBackgroundImage(imageWithColor(color: (backgroundColor != nil) ? backgroundColor! : UIColor.clear), for: .normal, barMetrics: .default)
        setBackgroundImage(imageWithColor(color: color), for: .selected, barMetrics: .default)
        setDividerImage(imageWithColor(color: (backgroundColor != nil) ? backgroundColor! : UIColor.clear), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
    }
    
    private func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width:  1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor);
        context!.fill(rect);
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image!
    }
    
    var type: Type {
        return Type(rawValue: selectedSegmentIndex)!
    }
    
    var mode: Mode {
        return Mode(rawValue: selectedSegmentIndex)!
    }
    
    enum `Type`: Int {
        case allow
        case block
    }
    
    enum Mode: Int {
        case number
        case text
    }
}
