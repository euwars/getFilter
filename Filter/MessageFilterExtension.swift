//
//  MessageFilterExtension.swift
//  filter
//
//  Created by Farzad Nazifi on 6/12/18.
//  Copyright © 2018 Farzad Nazifi. All rights reserved.
//

import IdentityLookup

final class MessageFilterExtension: ILMessageFilterExtension {}

extension MessageFilterExtension: ILMessageFilterQueryHandling {
    
    func handle(_ queryRequest: ILMessageFilterQueryRequest, context: ILMessageFilterExtensionContext, completion: @escaping (ILMessageFilterQueryResponse) -> Void) {
        // First, check whether to filter using offline data (if possible).


        NSLog("BBBBBB")
        let res = ILMessageFilterQueryResponse()
        res.action = .filter
        completion(res)
    }
}
