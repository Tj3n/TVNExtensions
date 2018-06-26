//
//  JSONDecoder.swift
//  TVNExtensions
//
//  Created by Tien Nhat Vu on 5/18/18.
//

import Foundation

extension JSONDecoder {
    
    /// Decode type from data, but with key as String, nested separate by ".", should not use `nestedContainer` together with this
    ///
    /// - Parameters:
    ///   - type: The type of the value to decode.
    ///   - data: The data to decode from.
    ///   - key: The key to decode from, nested separated by ".", if empty, dirrectly decode T.Type
    /// - Returns: A value of the requested type.
    /// - throws: `DecodingError.dataCorrupted` if values requested from the payload are corrupted, or if the given data is not valid JSON.
    /// - throws: An error if any value throws an error during decoding.
    public func decode<T>(_ type: T.Type, from data: Data, with keyPath: String) throws -> T where T : Decodable {
        guard !keyPath.isEmpty else {
            return try self.decode(T.self, from: data)
        }
        
        self.userInfo[CodingUserInfoKey(rawValue: "my_model_key")!] = keyPath
        let model = try self.decode(ModelResponse<T>.self, from: data).nested
        return model
    }
    
    private struct Key: CodingKey {
        let stringValue: String
        init?(stringValue: String) {
            self.stringValue = stringValue
            self.intValue = nil
        }
        
        let intValue: Int?
        init?(intValue: Int) {
            return nil
        }
    }
    
    /// Dummy model that handles model extracting logic from a key
    private struct ModelResponse<NestedModel: Decodable>: Decodable {
        let nested: NestedModel
        
        public init(from decoder: Decoder) throws {
            // Split nested paths with '.'
            var keyPaths = (decoder.userInfo[CodingUserInfoKey(rawValue: "my_model_key")!]! as! String).split(separator: ".")
            
            // Get last key to extract in the end
            let lastKey = String(keyPaths.popLast() ?? "")
            
            // Loop getting container until reach final one
            var targetContainer = try decoder.container(keyedBy: Key.self)
            for k in keyPaths {
                let key = Key(stringValue: String(k))!
                targetContainer = try targetContainer.nestedContainer(keyedBy: Key.self, forKey: key)
            }
            nested = try targetContainer.decode(NestedModel.self, forKey: Key(stringValue: lastKey)!)
        }
    }
}
