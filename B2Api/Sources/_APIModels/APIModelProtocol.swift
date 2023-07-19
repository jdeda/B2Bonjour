//
//  APIModelProtocol.swift
//  
//
//  Created by Jesse Deda on 7/19/23.
//

import Foundation

protocol APIModel {
    func urlRequest() throws -> URLRequest
}
