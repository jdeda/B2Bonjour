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
    // MARK: - Request -
    /**
     This is the type that we have created that will become the body of the POST URL request.
     */
    public struct Request: Codable {
        public let accountId: String
    }
    
    // MARK: - Response -
    /**
     This is the type that we use to map the json from the server response for this request.
     */
    public struct Response: Codable {
        public var buckets: [Bucket] = []

        // MARK: - Bucket -
        /**
         This is the object we really care.
         */
        public struct Bucket: Codable, Equatable {
            public let accountId: String
            public let bucketName: String
            public let bucketId: String
            public let bucketType: String
            // trigger decoding error foo: String
        }
    }

    /**
     The following are dependencies that we need to get this API done
     So we keep copies of them here
     So the person using the API will hae to create an instance of Self
     with these values
     */
    /// attributes required at time of init
    public let auth: Authentication
    
    public init(auth: Authentication) {
        self.auth = auth
    }
}
