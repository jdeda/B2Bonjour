//
//  JSONEncoder+Caching.swift
//  B2Api
//
//  Created by Klajd Deda on 7/20/23.
//

import Foundation
import Log4swift

extension URL {
    static func cacheURL(_ apiName: String) -> Self {
        URL.init(fileURLWithPath: #file)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("_Caches")
            .appendingPathComponent(apiName)
            .appendingPathExtension("json")
    }
}

// MARK: - Caching Conformance
extension JSONEncoder {
    public func archive<Value>(_ value: Value, _ apiName: String) -> Value where Value: Codable {
        let cacheURL = URL.cacheURL(apiName)

        Log4swift[Self.self].info("apiName: \(apiName)")
        self.outputFormatting = .prettyPrinted
        let data = try? self.encode(value)

        try? (data ?? Data()).write(to: cacheURL)
        return value
    }
}

// MARK: - Caching Conformance
extension JSONDecoder {
    public func unarchive<Value>(_ type: Value.Type, _ apiName: String) -> Value? where Value: Codable {
        let cacheURL = URL.cacheURL(apiName)

        if let data = try? Data.init(contentsOf: cacheURL) {
            return try? self.decode(type, from: data)
        }
        return nil
    }
}

extension Array where Element == ListBuckets.Response.Bucket {
    public func archive(_ apiName: String) throws -> Self {
        JSONEncoder().archive(self, apiName)
    }
    public static func unarchive(_ apiName: String) -> Self {
        JSONDecoder().unarchive([ListBuckets.Response.Bucket].self, apiName) ?? []
    }
}

extension Authentication {
    public func archive(_ apiName: String) -> Self {
        JSONEncoder().archive(self, apiName)
    }

    public static func unarchive(_ apiName: String) -> Self {
        JSONDecoder().unarchive(Self.self, apiName) ?? .empty
    }
}
