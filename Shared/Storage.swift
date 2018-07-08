//
//  Storage.swift
//  getFilter
//
//  Created by Farzad Nazifi on 7/7/18.
//  Copyright © 2018 Farzad Nazifi. All rights reserved.
//

import Foundation
import SQLite
import PromiseKit
import PhoneNumberKit

class Storage {
    // Database
    let db = try! Connection(FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.getfilter")!.appendingPathComponent("db.sqlite3").absoluteString)
    
    // Tables
    let users = Table("user")
    let crowds = Table("crowd")
    
    // Expressions
    // User
    let id = Expression<String>("id")
    let m = Expression<String?>("m")
    let n = Expression<String?>("n")
    let _r = Expression<String>("_r")
    let u = Expression<String>("u")
    let y = Expression<String>("y")
    let h = Expression<Bool>("h")
    let s = Expression<Bool>("s")
    
    // Crowd
    let nu = Expression<String>("nu")
    let w = Expression<Int>("w")
    
    enum Errors: Error {
        case wrongRule
    }
    
    init() {
        do {
            try db.run(users.create { t in
                t.column(id, primaryKey: true)
                t.column(m)
                t.column(n)
                t.column(_r)
                t.column(u)
                t.column(y)
                t.column(h)
                t.column(s)
            })
            
            try db.run(crowds.create { t in
                t.column(nu, primaryKey: true)
                t.column(w)
            })
            
        } catch { }
    }
    
    func newUpdateRule(rule: UserRule) -> Promise<Void> {
        return firstly {
            addUpdateRule(rule: rule)
            }.then { (rowID) -> Promise<Void> in
                return self.sendDataChangedNotification()
        }
    }
    
    func deleteRule(id: String) -> Promise<Void> {
        return firstly {
            removeUserRule(id: id)
            }.then { (rowID) -> Promise<Void> in
                return self.sendDataChangedNotification()
        }
    }
    
    private func addUpdateRule(rule: UserRule) -> Promise<Int64> {
        return Promise<Int64> { seal in
            do {
                guard (rule.m != nil || rule.n != nil) else{
                    throw Errors.wrongRule
                }
                
                
                let local = users.filter(id == rule.id)
                let count = try db.scalar(local.count)

                if count > 0 {
                    try db.run(local.update(m <- rule.m, n <- rule.n, _r <- rule.r.rawValue, s <- rule.synced))
                    seal.fulfill(0)
                } else {
                    let newRule = users.insert(id <- rule.id, m <- rule.m, n <- rule.n, _r <- rule.r.rawValue, u <- rule.u, y <- rule.y, h <- rule.hidden, s <- rule.synced)
                    let ruleRow = try db.run(newRule)
                    seal.fulfill(ruleRow)
                }

            } catch let err {
                seal.reject(err)
            }
        }
    }
    
    private func sendDataChangedNotification() -> Promise<Void> {
        return Promise<Void> { seal in
            NotificationCenter.default.post(Notification(name: .dataReload))
            seal.fulfill(())
        }
    }
    
    private func getUnsycned() -> Promise<([UserRule], [UserRule])> {
        return Promise<([UserRule], [UserRule])> { seal in
            do {
                let removedSelect = users.filter(h == true)
                let removed = try db.prepare(removedSelect)
                let removedRules = self.mapped(seq: removed)
                
                let newUpdateSelect = users.filter(s == false)
                let newUpdate = try db.prepare(newUpdateSelect)
                let newUpdateRules = self.mapped(seq: newUpdate)
                
                seal.fulfill((removedRules, newUpdateRules))
            } catch let err {
                seal.reject(err)
            }
        }
    }
    
    private func mapped(seq: AnySequence<Row>) -> [UserRule] {
        return seq.map({ (row) -> UserRule in
            return UserRule(id: row[id], m: row[m], n: row[n], r: UserRule.Rule(rawValue: row[_r])!, u: row[u], y: row[y], synced: row[s], hidden: row[h])
        })
    }
    
    func changeUserRuleSync(id: String, status: Bool) -> Promise<Void> {
        return Promise<Void> { seal in
            do {
                let select = users.filter(self.id == id)
                try db.run(select.update(s <- status))
                seal.fulfill(())
            } catch let err {
                seal.reject(err)
            }
        }
    }
    
    private func removeUserRule(id: String) -> Promise<Void> {
        return Promise<Void> { seal in
            do {
                let select = users.filter(self.id == id)
                try db.run(select.update(h <- true))
                seal.fulfill(())
            } catch let err {
                seal.reject(err)
            }
        }
    }
    
    var rules: [UserRule] {
        let select = users.filter(h == false)
        guard let prepared = try? db.prepare(select) else { return [UserRule]() }
        return mapped(seq: prepared)
    }
}


struct UserRule: Codable {
    enum ContentType: String, Codable {
        case t
        case n
    }
    
    enum Rule: String, Codable {
        case a
        case b
    }
    
    let id: String
    var m: String?
    var n: String?
    let r: Rule
    let u: String
    let y: String
    let hidden: Bool
    var synced: Bool
    
    init(m: String?, n: String?, r: Rule, u: String, y: String) {
        id = String(UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased().prefix(24))
        self.m = m
        self.n = n
        self.r = r
        self.u = u
        self.y = y
        self.synced = false
        self.hidden = false
    }
    
    init(id: String, m: String?, n: String?, r: Rule, u: String, y: String, synced: Bool, hidden: Bool) {
        self.id = id
        self.m = m
        self.n = n
        self.r = r
        self.u = u
        self.y = y
        self.synced = synced
        self.hidden = hidden
    }
}

extension Notification.Name {
    static let dataReload = Notification.Name("DataChanged")
}
