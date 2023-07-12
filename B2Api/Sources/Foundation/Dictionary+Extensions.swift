//
//  Dictionary+Extensions.swift
//  B2Api
//
//  Created by Klajd Deda on 3/27/23.
//  Copyright © 2023 Backblaze. All rights reserved.
//

import Foundation
import Log4swift

// MARK: - Dictionary (Extensions) -

extension Dictionary where Key: Equatable {
    /// Adds a dictionary to another. If a key exists in both dictionaries, the new one will override
    /// the original.
    func appending(_ headers: [Key: Value]) -> Self {
        var copy = self
        
        for header in headers {
            copy[header.key] = header.value
        }
        return copy
    }
}
