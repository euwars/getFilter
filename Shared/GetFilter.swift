//
//  GetFilter.swift
//  GetFilter
//
//  Created by Farzad Nazifi on 6/13/18.
//  Copyright © 2018 Farzad Nazifi. All rights reserved.
//

import Foundation
import IdentityLookup

class GetFilter {
    let ai = GetFilterSpamClassification()
    
    init() {
        
    }
    
    
    func evaluate(message: String) -> ILMessageFilterAction {
        
        // ovveride
        
        

        
        
        
        
        guard let prediction = try? ai.prediction(text: message) else {
            return .none
        }

        if prediction.label == "spam" {
            return .filter
        } else {
            return .allow
        }
    }
}
