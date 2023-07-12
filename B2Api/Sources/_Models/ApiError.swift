//
//  ApiError.swift
//  B2Api
//
//  Created by Klajd Deda on 3/28/23.
//  Copyright © 2023 Backblaze. All rights reserved.
//

import Foundation

public struct ApiError: Equatable, Error, Codable, Hashable {
    // the HTTP 'status' (not 200, because that'd be Ok)
    public var status: Int
    
    // the single token 'code'
    public var code: String
    
    // the human-readable 'message'
    public var message: String
}
