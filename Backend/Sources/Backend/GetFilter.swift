//
//  GetFilter.swift
//  Backend
//
//  Created by Farzad Nazifi on 7/1/18.
//

import Foundation
import Kitura
import MongoKitten
import BSON
import CryptoSwift

class GetFilter {
    let router = Router()
    let numCol: MongoKitten.Collection!
    let mesCol: MongoKitten.Collection!
    let userCol: MongoKitten.Collection!
    
    init() throws {
        guard CommandLine.argc == 3 else {
            throw MongoError.invalidURI(uri: CommandLine.arguments[1])
        }
        let cs = try ClientSettings(CommandLine.arguments[1])
        let server = try Server(cs)
        let db = Database(named: "rule", atServer: server)
        self.numCol = db["number"]
        self.mesCol = db["message"]
        self.userCol = db["user"]
        router.post("rule", handler: createBumpRule)
        router.delete("rule", handler: deleteRule)
        router.get("user", handler: userRules)
        router.get("country", handler: countryRules)
    }
    
    func createBumpRule(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) {
        do {
            guard let str = try request.readString(), let bytes = Data(base64Encoded: str)?.bytes else {
                response.send(status: .notAcceptable)
                next()
                return
            }
            
            let decrypted = try ChaCha20.init(key: CommandLine.arguments[2], iv: String(CommandLine.arguments[2].prefix(12))).decrypt(bytes)
            
            guard var userRule = try? JSONDecoder().decode(UserRule.self, from: Data(bytes: decrypted)), userRule.y.count > 0, userRule.u.count > 0, userRule.id.count == 24 else {
                response.send(status: .notAcceptable)
                next()
                return
            }
            
            if var update = try self.userCol.findOne(Query(["_id": try ObjectId(userRule.id)] as Document)) {
                update["d"] = Date()
                try self.userCol.findAndUpdate(Query(["_id": try ObjectId(userRule.id)] as Document), with: update)
                response.send(status: .OK)
                next()
                return
            }
            
            if let message = userRule.m {
                let status: Message.Status
                if userRule.r == .a {
                    status = .ham
                }else{
                    status = .spam
                }
                try mesCol.append(Message(m: message, s: status).doc())
            }
            
            if let number = userRule.n {
                if var exist = try numCol.findOne(Query(["n": number, "y": userRule.y])) {
                    
                    if userRule.r == .a {
                        exist["w"] = Int(exist["w"])! + 1
                    }else{
                        exist["w"] = Int(exist["w"])! - 1
                    }
                    
                    exist["d"] = Date()
                    
                    try self.numCol.update(Query(["n" == number, "y" == userRule.y]), to: exist)
                } else {
                    let newNumber = Number(d: Date(), n: number, w: userRule.r == .a ? 1 : 0, y: userRule.y)
                    try self.numCol.append(newNumber.doc())
                }
            }
            
            userRule.d = Date()
            
            try self.userCol.append(userRule.doc())
            response.send(status: .OK)
            next()
        } catch let err {
            print(err)
            response.send(status: .internalServerError)
            next()
        }
    }
    
    func deleteRule(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) {
        do {
            guard let user = request.queryParameters["user"], let id = request.queryParameters["id"] else {
                response.send(status: .notAcceptable)
                next()
                return
            }
            
            let q: Query = "_id" == (try ObjectId(id)) && "u" == user
            try self.userCol.findAndRemove(q)
            response.send(status: .OK)
            next()
        } catch let err {
            print(err)
            response.send(status: .internalServerError)
            next()
        }
    }
    
    func userRules(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) {
        do {
            guard let user = request.queryParameters["user"], user.count > 3 else {
                response.send(status: .notAcceptable)
                next()
                return
            }
            
            var skip = 0
            if let skipq = request.queryParameters["skip"], let skipi = Int(skipq) {
                skip = skipi
            }
            
            var date = Date(timeIntervalSince1970: 0)
            if let dateq = request.queryParameters["date"], let datei = Int(dateq) {
                date = Date(timeIntervalSince1970: TimeInterval(datei))
            }
            
            
            let q: Query = "u" == user && "d" >= date
            let matchingEntities: CollectionSlice<Document> = try self.userCol.find(q, skipping: skip, limitedTo: 1000)
            
            let all = matchingEntities.map { (doc) -> [String: Any] in
                var noDate = doc
                noDate.removeValue(forKey: "d")
                return noDate.dictionaryRepresentation
            }
            
            let encrypted = try ChaCha20.init(key: CommandLine.arguments[2], iv: String(CommandLine.arguments[2].prefix(12))).encrypt(all.makeBinary())
            response.send(Data(bytes: encrypted).base64EncodedString())
            next()
        } catch let err {
            print(err)
            response.send(status: .internalServerError)
            next()
        }
    }
    
    func countryRules(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) {
        do {
            guard let countriesString = request.queryParameters["country"], countriesString.count > 1 else {
                response.send(status: .notAcceptable)
                next()
                return
            }
            let countries = countriesString.components(separatedBy: "|")
            
            var skip = 0
            if let skipq = request.queryParameters["skip"], let skipi = Int(skipq) {
                skip = skipi
            }
            
            var date = Date(timeIntervalSince1970: 0)
            if let dateq = request.queryParameters["date"], let datei = Int(dateq) {
                date = Date(timeIntervalSince1970: TimeInterval(datei))
            }
            
            var result: [String: [[String: Any]]] = [:]
            
            try countries.forEach { (country) in
                let q: Query = "y" == country && "d" >= date
                let matchingEntities: CollectionSlice<Document> = try self.numCol.find(q, skipping: skip, limitedTo: 1000)
                let countryAll = matchingEntities.map { (doc) -> [String: Any] in
                    var noID = doc
                    noID.removeValue(forKey: "_id")
                    noID.removeValue(forKey: "d")
                    noID.removeValue(forKey: "y")
                    noID.removeValue(forKey: "u")
                    return noID.dictionaryRepresentation
                }
                
                result[country] = countryAll
            }
            
            let encrypted = try ChaCha20.init(key: CommandLine.arguments[2], iv: String(CommandLine.arguments[2].prefix(12))).encrypt(result.makeBinary())
            response.send(Data(bytes: encrypted).base64EncodedString())
            next()
        } catch let err {
            print(err)
            response.send(status: .internalServerError)
            next()
        }
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
    var d: Date?
    let m: String?
    let n: String?
    let r: Rule
    let u: String
    let y: String
    
    var _id: ObjectId {
        let new = String(UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased().prefix(24))
        do {
            return try ObjectId(id)
        }catch{
            return try! ObjectId(new)
        }
    }
    
    var t: ContentType {
        if (m != nil) {
            return .t
        }
        return .n
    }
    
    func doc() -> Document {
        return ["_id": _id,
                "d": d,
                "m": m,
                "n": n,
                "r": r.rawValue,
                "t": t.rawValue,
                "u": u,
                "y": y
            ] as Document
    }
}

struct Message {
    let m: String // Message
    let d = Date()
    enum Status: String {
        case ham
        case spam
    }
    let s: Status // Status
    
    func doc() -> Document {
        return ["m": m,
                "d": d,
                "s": s.rawValue
            ] as Document
    }
}

struct Number {
    let _id = try! ObjectId(String(UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased().prefix(24)))
    let d: Date
    let n: String // Number
    let w: Int // Weight
    let y: String // Country
    
    func doc() -> Document {
        return ["_id": _id,
                "d": d,
                "n": n,
                "w": w,
                "y": y
            ] as Document
    }
}
