//
//  GetFilterProvider.swift
//  getFilter
//
//  Created by Farzad Nazifi on 7/3/18.
//  Copyright © 2018 Farzad Nazifi. All rights reserved.
//

import Foundation
import Moya
import PromiseKit

enum GetFilterProvider {
    case addUpdateRule(encrypted: String)
    case removeRule(user: String, id: String)
    case userRules(user: String, lastSync: Date?, skip: Int?)
    case countryRules(country: String, lastSync: Date?, skip: Int?)
}

extension GetFilterProvider: TargetType {
    var baseURL: URL {
        return URL(string: "http://192.168.2.1:8080/")!
    }
    
    var path: String {
        switch self {
        case .addUpdateRule, .removeRule:
            return "rule"
        case .userRules:
            return "user"
        case .countryRules:
            return "country"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .addUpdateRule:
            return .post
        case .removeRule:
            return .delete
        case .userRules, .countryRules:
            return .get
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .addUpdateRule(let encrypted):
            return .requestData(encrypted.data(using: .utf8)!)
        default:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        var headers: [String : String]? = nil
        switch self {
        case .addUpdateRule:
            return ["Content-Type" : "text/plain; charset=utf-8"]
        case .removeRule(let user, let id):
            headers = [:]
            headers!["user"] = user
            headers!["id"] = id
        case .userRules(let user, let lastSync, let skip):
            headers = [:]
            headers!["user"] = user
            
            if let lastSync = lastSync {
                headers!["date"] = "\(lastSync.timeIntervalSince1970)"
            }
            
            if let skip = skip {
                headers!["skip"] = "\(skip)"
            }
        case .countryRules(let country, let lastSync, let skip):
            headers = [:]
            headers!["country"] = country
            
            if let lastSync = lastSync {
                headers!["date"] = "\(lastSync.timeIntervalSince1970)"
            }
            
            if let skip = skip {
                headers!["skip"] = "\(skip)"
            }
        }
        return headers
    }
}

extension MoyaProvider {
    public typealias PendingRequestPromise = (promise: Promise<Moya.Response>, cancellable: Cancellable)
    
    public func request(target: Target,
                        queue: DispatchQueue? = nil,
                        progress: Moya.ProgressBlock? = nil) -> Promise<Moya.Response> {
        return requestCancellable(target: target,
                                  queue: queue,
                                  progress: progress).promise
    }
    
    public func requestDecoded<T>(target: Target, type: T.Type) -> Promise<T> where T: Decodable {
        return Promise<T> { seal in
            request(target: target).done({ (response) in
                do {
                    let decoded = try JSONDecoder().decode(type, from: response.data)
                    seal.fulfill(decoded)
                } catch let err {
                    seal.reject(err)
                }
            }).catch({ (err) in
                seal.reject(err)
            })
        }
    }
    
    func requestCancellable(target: Target,
                            queue: DispatchQueue?,
                            progress: Moya.ProgressBlock? = nil) -> PendingRequestPromise {
        let pending = Promise<Moya.Response>.pending()
        let completion = promiseCompletion(fulfill: pending.resolver.fulfill, reject: pending.resolver.reject)
        let cancellable = request(target, callbackQueue: queue, progress: progress, completion: completion)
        
        return (pending.promise, cancellable)
    }
    
    private func promiseCompletion(fulfill: @escaping (Moya.Response) -> Void,
                                   reject: @escaping (Swift.Error) -> Void) -> Moya.Completion {
        return { result in
            switch result {
            case let .success(response):
                fulfill(response)
            case let .failure(error):
                reject(error)
            }
        }
    }
}
