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
    
    init() throws {
        guard CommandLine.argc == 3 else {
            throw MongoError.invalidURI(uri: CommandLine.arguments[1])
        }
        let cs = try ClientSettings(CommandLine.arguments[1])
        let server = try Server(cs)
        let db = Database(named: "rule", atServer: server)
        self.numCol = db["number"]
        self.mesCol = db["message"]
        router.post("new", handler: createBumpRule)
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

            guard var rule = try? JSONDecoder().decode(Number.self, from: Data(bytes: decrypted)), rule.u.count > 3, !(rule.w != nil) else {
                response.send(status: .notAcceptable)
                next()
                return
            }
            
            if let message = rule.m {
                let status: Message.Status
                if rule.r == .a {
                    status = .ham
                }else{
                    status = .spam
                }
                try mesCol.append(Message(m: message, s: status).doc())
            }
            

            if var exist = try numCol.findOne(Query(rule.doc(mode: .find))) {
                
                if rule.r == .a {
                    exist["w"] = Int(exist["w"])! + 1
                }else{
                    exist["w"] = Int(exist["w"])! - 1
                }
                
                exist["d"] = Date()
                
                try self.numCol.update(Query(rule.doc(mode: .find)), to: exist)
                response.send(status: .accepted)
                next()
                return
            }
            
            if rule.r == .a {
                rule.w = 1
            }else {
                rule.w = -1
            }
            rule.d = Date()

            try self.numCol.append(rule.doc(mode: .plain))
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
            
            let query = Query(["u": user] as Document)
            let matchingEntities: CollectionSlice<Document> = try self.numCol.find(query, skipping: skip, limitedTo: 1000)
            let amountOfMatchingEntities: Int = try self.numCol.count(query)
            
            let all = matchingEntities.map { (doc) -> [String: Any] in
                var noID = doc
                noID.removeValue(forKey: "_id")
                noID.removeValue(forKey: "d")
                return noID.dictionaryRepresentation
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
            
            var result: [String: [[String: Any]]] = [:]
            
            try countries.forEach { (country) in
                let query = Query(["y": country] as Document)
                let matchingEntities: CollectionSlice<Document> = try self.numCol.find(query, skipping: skip, limitedTo: 1000)
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

struct Number: Codable {
    enum ContentType: String, Codable {
        case t
        case n
    }
    
    enum Rule: String, Codable {
        case a
        case b
    }
    
    enum QueryMode {
        case find
        case plain
    }
    
    var _id: ObjectId? = try! ObjectId(String(UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased().prefix(24)))
    var d: Date?
    let n: String // Number
    let m: String? // Message
    let r: Rule // Rule
    let u: String // User
    let y: String // Country
    var w: Int? // Weight
    
    func doc(mode: QueryMode) -> Document {
        
        switch mode {
        case .find:
            return ["n": n,
                    "r": r.rawValue,
                    "y": y,
                    ] as Document
        case .plain:
            return ["_id": _id,
                    "d": d,
                    "n": n,
                    "r": r.rawValue,
                    "u": u,
                    "y": y,
                    "w": w,
                    ] as Document
        }
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
