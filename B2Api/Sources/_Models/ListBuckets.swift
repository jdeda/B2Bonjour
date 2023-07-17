//
//  ListBuckets.swift
//  B2Api
//
//  Created by Klajd Deda on 3/27/23.
//  Copyright © 2023 Backblaze. All rights reserved.
//

import Foundation

/// Container for all the types related to the B2ApiClient.listBuckets API.
public struct ListBuckets {
    public struct Request: Codable {
        public let accountId: String
    }
    
    // MARK: - Response -
    public struct Response: Codable {
        public var buckets: [Bucket] = []

        // MARK: - Bucket -
        public struct Bucket: Codable, Equatable {
            public let accountId: String
            public let bucketName: String
            public let bucketId: String
            public let bucketType: String
            // trigger decoding error foo: String
        }
    }
    
    /// attributes required at time of init
    public let auth: Authentication
    
    public init(auth: Authentication) {
        self.auth = auth
    }
}
