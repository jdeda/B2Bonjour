//
//  URLQueryItem+Extensions.swift
//  B2Api
//
//  Created by Klajd Deda on 3/27/23.
//  Copyright © 2023 Backblaze. All rights reserved.
//

import Foundation
import Log4swift

// MARK: - URLQueryItem (Extensions) -

public extension URLQueryItem {
    var percentEscaped: URLQueryItem {
        URLQueryItem(name: name, value: (value ?? "").percentEscapedString)
    }
}
