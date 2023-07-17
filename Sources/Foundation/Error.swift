//
//  ErrorExtension.swift
//  Alamofire
//
//  Created by Tien Nhat Vu on 11/24/17.
//

import Foundation

public let TVNErrorDomain = "com.tvn.errorDomain"

public extension NSError {
    var jsonString: String? {
        get {
            let dict = ["code": String(self.code),
                        "description": self.localizedDescription]
            if let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: []) {
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    return jsonString
                }
            }
            return nil
        }
    }
}

public extension Error {
    var jsonString: String? {
        get {
            let err = self as NSError
            var dict = ["code": String(err.code)]
            if let localizedDescription = err.userInfo[NSLocalizedDescriptionKey] as? String {
                dict["description"] = localizedDescription
            } else {
                dict["description"] = "Unknow error"
            }
            
            if let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: []) {
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    return jsonString
                }
            }
            
            return nil
        }
    }
}
