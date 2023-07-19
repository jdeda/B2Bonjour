//
//  ListEntriesInDir.swift
//  B2Api
//
//  Created by Klajd Deda on 3/27/23.
//  Copyright © 2023 Backblaze. All rights reserved.
//

import Foundation

/// Container for all the types related to the B2ApiClient.listEntriesInDir API.
public struct ListEntriesInDir {
    public struct Request: Codable {
        public let bucketId: String
        public let startFileName: String?
        // 10000 is max per request July 2019
        public var maxFileCount: Int = 10000
        /// The delimiter for B2 virtual directories is "/" by default.
        /// When delimiter is nil, request returns all files instead of separating them into virtual folders.
        public let delimiter: String?
        public let prefix: String? // the base path
    }
    
    // MARK: - Response
    public struct Response: Codable {
        public let files: [File]
        public let nextFileID: String?
        public let nextFileName: String?

        // MARK: - File
        public struct File: Codable {
            public let accountID: String
            public let action: String
            public let bucketID: String
            public let contentLength: Int
            public let contentMd5: String?
            public let contentSha1: String
            public let contentType: String
            public let fileID: String
            public let fileInfo: FileInfo
            public let fileName: String
            public let fileRetention: FileRetention
            public let legalHold: FileRetention
            public let serverSideEncryption: ServerSideEncryption
            public let uploadTimestamp: Int

            enum CodingKeys: String, CodingKey {
                case accountID = "accountId"
                case action
                case bucketID = "bucketId"
                case contentLength
                case contentMd5
                case contentSha1
                case contentType
                case fileID = "fileId"
                case fileInfo
                case fileName
                case fileRetention
                case legalHold
                case serverSideEncryption
                case uploadTimestamp
            }
        }
        
        // MARK: - FileInfo
        public struct FileInfo: Codable {
            public let bucketID, date, snapshotName, sid, srcLastModifiedMillis: String?

            enum CodingKeys: String, CodingKey {
                case bucketID = "bucket_id"
                case date
                case snapshotName = "snapshot_name"
                case sid
                case srcLastModifiedMillis = "src_last_modified_millis"
            }
        }
        
        // MARK: - FileRetention
        public struct FileRetention: Codable {
            public let isClientAuthorizedToRead: Bool
            public let value: Value?
        }
        
        // MARK: - Value
        public struct Value: Codable {
            public let mode: JSONNull?
            public let retainUntilTimestamp: JSONNull?
        }
        
        // MARK: - ServerSideEncryption
        public struct ServerSideEncryption: Codable {
            public let algorithm: JSONNull?
            public let mode: JSONNull?
        }
    }

    /// attributes required at time of init
    public let auth: Authentication
    public let bucketId: String
    public let startFileName: String?
    public let shouldShowFileVersions: Bool
    public let shouldReturnFolders: Bool
    
    public init(auth: Authentication, bucketId: String, startFileName: String?, shouldShowFileVersions: Bool, shouldReturnFolders: Bool) {
        self.auth = auth
        self.bucketId = bucketId
        self.startFileName = startFileName
        self.shouldShowFileVersions = shouldShowFileVersions
        self.shouldReturnFolders = shouldReturnFolders
    }
}
