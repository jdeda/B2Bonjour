//
//  URLRequest+Extensions.swift
//  B2Api
//
//  Created by Klajd Deda on 3/27/23.
//  Copyright © 2023 Backblaze. All rights reserved.
//

import Foundation
import Log4swift

// MARK: - URLRequest (Extensions) -

extension URLRequest {
    /// Fetch the data from the request, and return a proper response instance of T.type or throw a B2Error.
    ///
    /// Happy path we get good json data and we map it to the response type T
    /// 1. Unhappy path, we get status code other than 200 and we map the data into an ApiError
    /// 2. Unhappy path, we get status code other than 200 and we are unable to map the data into ApiError
    /// 3. Unhappy path, we get errors parsing the json, for example our object does not match the server json
    ///
    /// - Parameters:
    ///     - type: The T.type to convert to
    ///     - decoder: An instance of JSONDecoder to decode
    /// - Returns: An instance of T.Type if the http response is ok and we are able to parse its data
    /// - Throws: B2Error if anything goes wrong. If we get a 'Retry-After' header fromt he server we
    /// will wrap the error to B2ApiError.retryAfterError
    ///
    func fetchResponse<T>(
        _ type: T.Type,
        decoder: JSONDecoder = JSONDecoder() // you can substitute one if you want a smarter encoder
    ) async throws -> T where T : Decodable {
        let (data, urlResponse) = try await URLSession.shared.data(for: self)
        let json = String(data: data, encoding: .utf8) ?? ""
        
        Log4swift[Self.self].info("urlResponse: \(urlResponse)")
#if DEBUG
        let fileName = "/tmp/crap.txt"
        Log4swift[Self.self].info("writing the response data to file: \(fileName)")
        try? data.write(to: URL(fileURLWithPath: fileName))
#endif
        
        guard let httpResponse = urlResponse as? HTTPURLResponse,
              httpResponse.statusCode == 200
        else {
            if let apiError = try? decoder.decode(ApiError.self, from: data) {
                // Unhappy path 1
                Log4swift[Self.self].info("apiError: \(apiError)")
                throw B2ApiError.serverError(apiError)
                    .mapAsRetryAfter(urlResponse.retryAfterSeconds)
            }
            // Unhappy path 2
            throw B2ApiError.unableToParseApiFromJSON(json)
                .mapAsRetryAfter(urlResponse.retryAfterSeconds)
        }
        
        do {
            return try decoder.decode(type, from: data)
        } catch {
            Log4swift[Self.self].error("json: \(json)")
            Log4swift[Self.self].error("error: \(error)")
            
            // Unhappy path 3
            throw B2ApiError.unableToParseApiFromJSON(json)
                .mapAsRetryAfter(urlResponse.retryAfterSeconds)
        }
    }
}
