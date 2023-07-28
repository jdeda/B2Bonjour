//
//  File.swift
//  
//
//  Created by Jesse Deda on 7/28/23.
//

// TODO: Put file headers
// TODO: Put API links for each file (add documentation)

import Foundation
/// Represent the B2 Native API `b2-list-file-names` endpoint.
/// https://www.backblaze.com/apidocs/b2-list-file-names
public struct ListFileNames {
    public struct Request: Codable {
        public var bucketId: String
        public var startFileName: String = ""
        public var maxFileCount: String = ""
        public var prefix: String = ""
        public var delimiter: String = ""
    }
    
    public struct Response: Codable {
        public let files: [File]
        public let nextFileName: String?
        
        public struct File: Codable {
            public let accountId: String
            public let action: String
            public let bucketId: String
            public let contentLength: Int
            public let contentSha1: String
            public let contentType: String?
            public let fieldId: String?
            //            public let fileInfo: [String: String]
            public let fileName: String
        }
    }
    
    public let auth: Authentication
    public let request: Request
}

extension ListFileNames: APIModel {
    func urlRequest() throws -> URLRequest {
        let relativeURL = "/b2api/v2/b2_list_file_names"
        let absoluteURL = self.auth.apiUrl.appendingPathComponent(relativeURL)
            .appendingQueryItem(name: "bucketId", value: self.request.bucketId)
            .appendingQueryItem(name: "startFileName", value: self.request.startFileName)
            .appendingQueryItem(name: "maxFileCount", value: self.request.maxFileCount)
            .appendingQueryItem(name: "prefix", value: self.request.prefix)
            .appendingQueryItem(name: "delimiter", value: self.request.delimiter)
        
        var urlRequest = URLRequest(url: absoluteURL)
        urlRequest.httpMethod = "GET"
        urlRequest.allHTTPHeaderFields = self.auth.authHeaders()
        return urlRequest
    }
}
