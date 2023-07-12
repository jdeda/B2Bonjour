//
//  B2ApiError.swift
//  B2Api
//
//  Created by Klajd Deda on 3/28/23.
//  Copyright © 2023 Backblaze. All rights reserved.
//

import Foundation

public indirect enum B2ApiError: Error, Equatable {
    case unableToCreateUrl
    case unableToParseApiFromJSON(String)
    case serverError(ApiError)
    case retryAfterError(seconds: Int, original: B2ApiError)

    case otherError
}

extension B2ApiError {
    /// If we get an honest retryAfterSeconds, than map self into .retryAfterError
    /// We can customize this
    func mapAsRetryAfter(_ retryAfterSeconds: Int?) -> Self {
        guard let retryAfterSeconds = retryAfterSeconds
        else { return self }
        
        return .retryAfterError(seconds: retryAfterSeconds, original: self)
    }
}
