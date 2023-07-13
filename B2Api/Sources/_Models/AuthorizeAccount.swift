//
//  AuthorizeAccount.swift
//  B2Api
//
//  Created by Jesse Deda on 7/12/23.
//  Copyright © 2023 Backblaze. All rights reserved.
//

import Foundation

// Container for all the types related to the B2ApiClient.authorizeAccount API.
public struct AuthorizeAccount {
    public struct Request: Codable {
      public let applicationKeyId: String
      public let applicationKey: String
      
      public init(applicationKeyId: String, applicationKey: String) {
        self.applicationKeyId = applicationKeyId
        self.applicationKey = applicationKey
      }

      func authHeader() -> [String: String]? {
        guard let data = String(applicationKeyId + ":" + applicationKey).data(using: .utf8)
        else { return nil }
        return ["Authorization": String("Basic" + data.base64EncodedString())]
      }
    }
    
  // MARK: - In reality, this is just the Authentication struct in _Models/Authentication.swift
    public struct Response: Codable {
      let accountId: String
      let authorizationToken: String
      let apiUrl: String
      
      public init(accountId: String, authorizationToken: String, apiUrl: String) {
        self.accountId = accountId
        self.authorizationToken = authorizationToken
        self.apiUrl = apiUrl
      }
    }
}
