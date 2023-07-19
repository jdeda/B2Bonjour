//
//  ListComputers.swift
//  B2Api
//
//  Created by Klajd Deda on 3/30/23.
//  Copyright © 2023 Backblaze. All rights reserved.
//

import Foundation

/// Container for all the types related to the B2ApiClient.listComputers API.
public struct ListComputers {
    
    // MARK: - Request
    public struct Request: Codable {
        public let accountId: String
    }
    
    // MARK: - Response -
    public struct Response: Codable {
        public var computers: [Computer] = []
        
        // MARK: - Computer -
        public struct Computer: Codable {
            public let displayName, mimeType, volumeID, fullyQualifiedFileName: String
            public let volatileFileID: String
            public let dot, dotDot: JSONNull?
            public let sizeInBytes, lastBackupDateMilllis: Int
            public let hguid: String
            public let numFilesBackedUp, numBytesBackedUp, numFilesSelectedForBackup, numBytesSelectedForBackup: Int
            public let numFilesRemaining, numBytesRemaining: Int
            public let hostOS: HostOS
            public let licenseState: LicenseState
            public let hasPrivateEncryption: Int
            
            enum CodingKeys: String, CodingKey {
                case displayName = "display_name"
                case mimeType = "mime_type"
                case volumeID = "volume_id"
                case fullyQualifiedFileName = "fully_qualified_file_name"
                case volatileFileID = "volatile_file_id"
                case dot
                case dotDot = "dot_dot"
                case sizeInBytes = "size_in_bytes"
                case lastBackupDateMilllis = "last_backup_date_milllis"
                case hguid
                case numFilesBackedUp = "num_files_backed_up"
                case numBytesBackedUp = "num_bytes_backed_up"
                case numFilesSelectedForBackup = "num_files_selected_for_backup"
                case numBytesSelectedForBackup = "num_bytes_selected_for_backup"
                case numFilesRemaining = "num_files_remaining"
                case numBytesRemaining = "num_bytes_remaining"
                case hostOS = "host_os"
                case licenseState = "license_state"
                case hasPrivateEncryption = "has_private_encryption"
            }
        }
        
        public enum HostOS: String, Codable {
            case mac = "mac"
        }
        
        public enum LicenseState: String, Codable {
            case paidUnlimited = "paid_unlimited"
        }
    }
    
    /// attributes required at time of init
    public let auth: Authentication
    public let clusterNum: String
    public let deviceId: String
    
    public init(auth: Authentication, clusterNum: String, deviceId: String) {
        self.auth = auth
        self.clusterNum = clusterNum
        self.deviceId = deviceId
    }
}

// MARK: - APIModel Conformance
extension ListComputers: APIModel {
    func urlRequest() throws -> URLRequest {
        let relativeURL = "api2/list_b1_computers"
        let absoluteURL = self.auth.apiUrl.appendingPathComponent(relativeURL)
            .appendingQueryItem(name: "user_id", value: self.auth.accountId)
            .appendingQueryItem(name: "bz_device_id", value: self.deviceId)
            .appendingQueryItem(name: "cluster_num", value: self.clusterNum)
        
        // Some POST requests may also want parameters in the url
        // and can have a nil body
        
        var urlRequest = URLRequest(url: absoluteURL)
        // in seconds
        urlRequest.timeoutInterval = 10.0
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = nil
        urlRequest.allHTTPHeaderFields = self.auth.authHeaders()
            .appending(["Account-Id": self.auth.accountId])
        // .appending(NetworkUtilities.defaultBackblazeHeaders)
        return urlRequest
    }
}
