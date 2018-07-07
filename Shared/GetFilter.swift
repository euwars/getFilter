//
//  GetFilter.swift
//  GetFilter
//
//  Created by Farzad Nazifi on 6/13/18.
//  Copyright © 2018 Farzad Nazifi. All rights reserved.
//

import Foundation
import IdentityLookup
import PromiseKit
import Moya
import CryptoSwift
import CloudKit
import SQLite

class GetFilter {
    let ai = GetFilterSpamClassification()
    let provider = MoyaProvider<GetFilterProvider>()
    let storage = Storage()

    init(readOnly: Bool) throws {
        
    }
    
    func getUser() -> Promise<String> {
        return Promise<String> { seal in
            let container = CKContainer.default()
            container.fetchUserRecordID(completionHandler: { (id, err) in
                if let id = id {
                    seal.fulfill(id.recordName)
                }
                
                if let err = err {
                    seal.reject(err)
                }
            })
        }
    }

    func evaluate(message: String) -> ILMessageFilterAction {
        
        // Check User Rules
        
        // Check CrowdSourcing
        
        // Check AI
        
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
