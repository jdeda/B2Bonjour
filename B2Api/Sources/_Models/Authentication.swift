//
//  Authentication.swift
//  B2Api
//
//  Created by Klajd Deda on 3/27/23.
//  Copyright © 2023 Backblaze. All rights reserved.
//

import Foundation

public struct Authentication {
    public let apiUrl: URL
    public let accountId: String
    public let authToken: String
    
    public init(apiUrl: URL, accountId: String, authToken: String) {
        self.apiUrl = apiUrl
        self.accountId = accountId
        self.authToken = authToken
    }
    
    public func authHeaders() -> [String: String] {
        let headers = ["Authorization": authToken]

//        #if DEBUG
//        if B2TestFlag.doTestDownloadCapExceeded {
//            // Add header before making upload-related API calls.
//            // This will cause a cap limit failure, allowing you to verify correct behavior of your code.
//            headers["X-Bz-Test-Mode"] = "force_cap_exceeded"
//        }
//        #endif

        return headers
    }

}
