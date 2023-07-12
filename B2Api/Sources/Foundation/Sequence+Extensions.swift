//
//  Sequence+Extensions.swift
//  B2Api
//
//  Created by Klajd Deda on 3/27/23.
//  Copyright © 2023 Backblaze. All rights reserved.
//

import Foundation
import Log4swift

// MARK: - Sequence (Extensions) -

/// Goofing around with async. Why is this not on the Standard Lib ?
/// Lifted from: https://www.swiftbysundell.com/articles/async-and-concurrent-forEach-and-map/
///
extension Sequence {
    public func asyncMap<T>(
        _ transform: (Element) async throws -> T
    ) async rethrows -> [T] {
        var values = [T]()

        for element in self {
            try await values.append(transform(element))
        }

        return values
    }
}
