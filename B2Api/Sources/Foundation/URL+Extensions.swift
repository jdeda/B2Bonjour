//
//  URL+Extensions.swift
//  B2Api
//
//  Created by Klajd Deda on 3/27/23.
//  Copyright © 2023 Backblaze. All rights reserved.
//

import Foundation
import Log4swift

// MARK: - URL (Extensions) -

public extension URL {
    func appendingQueryItem(name: String, value: String) -> URL {
        return appending(queryItems: [URLQueryItem(name: name, value: value)])
    }

    func appending(queryItem: URLQueryItem) -> URL {
        return appending(queryItems: [queryItem])
    }

    func appending(queryItems: [URLQueryItem]) -> URL {
        guard !queryItems.isEmpty,
              var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: false)
        else { return self }

        var updatedItems = urlComponents.queryItems ?? [URLQueryItem]()
        updatedItems.append(contentsOf: queryItems)
        updatedItems = updatedItems
            .filter {
                guard let value = $0.value,
                      !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                      !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                else { return false }
                return true
            }
        urlComponents.queryItems = updatedItems
        guard let rv = urlComponents.url
        else { return self }
        return rv
    }
}
