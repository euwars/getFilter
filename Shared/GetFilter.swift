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
import OneSignal

class GetFilter {
    let ai = GetFilterSpamClassification()
    let provider = MoyaProvider<GetFilterProvider>()
    let storage = Storage()
    
    var userID: String!
    
    let tempKey = "djska321hjh321jkbhjdgsahg321hg31"
    
    init(readOnly: Bool) throws {
        NotificationCenter.default.addObserver(self, selector: #selector(ssync), name: .dataReload, object: nil)
    }
    
    @objc private func ssync() {
        _ = sync()        
    }
    
    var isSyncing = false
    func sync() -> Promise<Void> {
        return Promise<Void> { seal in
            if !isSyncing {
                isSyncing = true
                firstly {
                    getUser()
                    }.then({ (user) -> Promise<Void> in
                        return self.syncDeletedUserRules()
                    }).then { (user) -> Promise<Void> in
                        return self.syncSendUserRules()
                    }.then { () -> Promise<Void> in
                        return self.syncGetUserRules()
                    }.then({ () -> Promise<Void> in
                        return self.syncCountryRules()
                    }).done { () in
                    }.catch { (err) in
                        print(err)
                    }.finally {
                        self.isSyncing = false
                        seal.fulfill(())
                }
            }else {
                seal.fulfill(())
            }
        }
    }
    
    func getUser() -> Promise<String> {
        return Promise<String> { seal in
            let container = CKContainer.default()
            container.fetchUserRecordID { (id, err) in
                if let id = id {
                    OneSignal.sendTag("user", value: id.recordName)
                    self.userID = id.recordName
                    seal.fulfill(id.recordName)
                }
                
                if let err = err {
                    seal.reject(err)
                }
            }
        }
    }
    
    private func syncSendUserRules() -> Promise<Void> {
        return Promise<Void> { seal in
            var tasks: [Promise<Void>] = []
            
            storage.getUnsycned().done({ (changes) in
                changes.0.forEach({ (rule) in
                    tasks.append(self.delete(rule: rule))
                })
                
                changes.1.forEach({ (rule) in
                    tasks.append(self.addUpdate(rule: rule))
                })
                
                
                when(fulfilled: tasks).done({ (s) in
                    seal.fulfill(())
                }).catch({ (err) in
                    seal.reject(err)
                })
                
            }).catch({ (err) in
                seal.reject(err)
            })
        }
    }
    
    private func syncDeletedUserRules() -> Promise<Void> {
        return Promise<Void> { seal in
            let date = Date()
            self.provider.request(target: GetFilterProvider.deletedRules(user: userID, lastSync: date)).done({ (response) in
                let s = Data(base64Encoded: response.data)!
                do {
                    let decrypted = try ChaCha20.init(key: self.tempKey, iv: String(self.tempKey.prefix(12))).decrypt(s.bytes)
                    let deleteds = try JSONDecoder().decode([String].self, from: Data(bytes: decrypted))
                    deleteds.forEach({ (rule) in
                        _ = self.storage.fullyRemoveUserRule(id: rule)
                    })
                    
                } catch let err {
                    seal.reject(err)
                }
                seal.fulfill(())
            }).catch({ (err) in
                seal.reject(err)
            })
        }
    }
    
    private func syncGetUserRules(skip: Int? = 0) -> Promise<Void> {
        return Promise<Void> { seal in
            let date = Date()
            self.provider.request(target: .userRules(user: userID, lastSync: date, skip: skip)).done({ (response) in
                let s = Data(base64Encoded: response.data)!
                do {
                    let decrypted = try ChaCha20.init(key: self.tempKey, iv: String(self.tempKey.prefix(12))).decrypt(s.bytes)
                    let rules = try JSONDecoder().decode([UserRule].self, from: Data(bytes: decrypted))
                    rules.forEach({ (rule) in
                        _ = self.storage.newUpdateRule(rule: rule)
                    })
                    
                    
                } catch let err {
                    seal.reject(err)
                }
                seal.fulfill(())
            }).catch({ (err) in
                seal.reject(err)
            })
        }
    }
    
    private func syncCountryRules() -> Promise<Void> {
        return Promise<Void> { seal in
            let date = Date()
            var skip = 0
            func fetch() {
                let country = "AT"
                self.provider.request(target: GetFilterProvider.countryRules(country: country, lastSync: date, skip: skip)).done({ (response) in
                    let s = Data(base64Encoded: response.data)!
                    do {
                        let decrypted = try ChaCha20.init(key: self.tempKey, iv: String(self.tempKey.prefix(12))).decrypt(s.bytes)
                        let countryRules = try JSONDecoder().decode([CountryRule].self, from: Data(bytes: decrypted))
                        countryRules.forEach({ (countryRule) in
                            _ = self.storage.addUpdateCountry(countryRule: countryRule)
                        })
                        
                        if countryRules.count == 1000 {
                            skip += 1000
                            fetch()
                        } else {
                            seal.fulfill(())
                        }
                        
                    } catch let err {
                        seal.reject(err)
                    }
                }).catch({ (err) in
                    seal.reject(err)
                })
            }
            
            fetch()
        }
    }
    
    private func addUpdate(rule: UserRule) -> Promise<Void> {
        return Promise<Void> { seal in
            let encoded = try! JSONEncoder().encode(rule)
            let encrypted = try! ChaCha20.init(key: self.tempKey, iv: String(self.tempKey.prefix(12))).encrypt(encoded.bytes)
            firstly {
                self.provider.request(target: .addUpdateRule(encrypted: encrypted.toBase64()!))
                }.then({ (resp) -> Promise<Void> in
                    return self.storage.changeUserRuleSync(id: rule.id, status: true)
                }).done { () in
                    seal.fulfill(())
                }.catch { (err) in
                    seal.reject(err)
            }
        }
    }
    
    private func delete(rule: UserRule) -> Promise<Void> {
        return Promise<Void> { seal in
            return firstly {
                self.provider.request(target: .removeRule(user: rule.u, id: rule.id))
                }.then({ (response) -> Promise<Void> in
                    return self.storage.fullyRemoveUserRule(id: rule.id)
                }).done({ () in
                    seal.fulfill(())
                }).catch({ (err) in
                    seal.reject(err)
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
