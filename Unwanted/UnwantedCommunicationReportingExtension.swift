//
//  UnwantedCommunicationReportingExtension.swift
//  Unwanted
//
//  Created by Farzad Nazifi on 8/19/18.
//  Copyright © 2018 Farzad Nazifi. All rights reserved.
//

import UIKit
import IdentityLookup
import IdentityLookupUI

class UnwantedCommunicationReportingExtension: ILClassificationUIExtensionViewController {
    
    var vc: NewRuleViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let gf = try! GetFilter(readOnly: false)
        vc = NewRuleViewController(gf: gf)
        transition(child: vc)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Notify the system when you have completed gathering information
        // from the user and you are ready with a classification response
        self.extensionContext.isReadyForClassificationResponse = true
    }
    
    
    // Customize UI based on the classification request before the view is loaded
    override func prepare(for classificationRequest: ILClassificationRequest) {
        // Configure your views for the classification request
        vc.saveButton.isHidden = true

        if let calls = (classificationRequest as? ILCallClassificationRequest) {
            guard let last = calls.callCommunications.last else {
                return
            }
            
            if let sender = last.sender {
                vc.numberField.text = sender
                vc.selectiveDidTap(selective: vc.phoneView)
            }
        }
        
        if let messages = (classificationRequest as? ILMessageClassificationRequest) {
            guard let last = messages.messageCommunications.last else {
                return
            }
            
            if let body = last.messageBody {
                vc.textField.text = body
                vc.selectiveDidTap(selective: vc.textView)
            }
            
            if let sender = last.sender {
                vc.numberField.text = sender
                vc.selectiveDidTap(selective: vc.phoneView)
            }
        }
    }
    
    // Provide a classification response for the classification request
    override func classificationResponse(for request:ILClassificationRequest) -> ILClassificationResponse {
        vc.saveTapped(UIButton())
        return ILClassificationResponse(action: .none)
    }
    
}
