//
//  URLResponse+Extensions.swift
//  B2Api
//
//  Created by Klajd Deda on 3/27/23.
//  Copyright © 2023 Backblaze. All rights reserved.
//

import Foundation
import Log4swift

// MARK: - URLResponse (Extensions) -

extension URLResponse {
    /// If there's a Retry-After header and it has a delay-seconds formatted value,
    /// this returns it.  (to be clear, if there's an HTTP-date value, we ignore it
    /// and keep looking for one with delay-seconds format.)
    ///
    /// Corresponds to B2WebApiHttpClientImpl.java::getRetryAfterSeconds
    ///
    /// - Returns: the delay-seconds from a Retry-After header, if any.  otherwise, nil.
    var retryAfterSeconds: Int? {
        let retryAfterHeader = "Retry-After"

        guard let response = self as? HTTPURLResponse,
              let headers = response.allHeaderFields as? [String: String],
              let retryAfter = headers[retryAfterHeader]
        else { return nil }
        
        return Int(retryAfter)
    }
}
