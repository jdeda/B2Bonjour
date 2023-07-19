//
//  B2ApiClient.swift
//  B2Api
//
//  Created by Klajd Deda on 3/28/23.
//  Copyright © 2023 Backblaze. All rights reserved.
//

import Foundation
import System
import Log4swift
import Dependencies
import XCTestDynamicOverlay

/// Entry point to define the APIs to the backend. This code will be used by anyone interested. SwiftUI
/// previews and testing. To learn more watch the @Dependency from the point free guys.
/// The dance here is simple.
///
/// 1. Start by defining a function, ie: listBuckets, one argument, async throws and returns a honest type, ie: ListBuckets.Response.Bucket
/// 2. In a separate file ie: 'ListBuckets' define the request, response and other types arguments you want to have in hand to
/// initiate the API and parse the results from the server
/// 3. Create an inner func that creates the URLRequest to properly suit this API
/// 4. Call fetchResponse on the urlrequest and parse the data into your honest response result. ie: ListBuckets.Response
/// 5. Extract and return the honest reply from this, ie: [ListBuckets.Response.Bucket]
///
/// Repeat these for each endpoint you care
///
public struct B2ApiClient {
    /// This method is a re-write of the B2Api.listBuckets() but it uses structured concurrency and the client
    /// architecture from TCA. It will allow us to write swiftUI previews and test cases much faster.
    ///
    /// What we want here is to make this funcs async. Since we are inside an async context
    /// we do not have to burden ourselves with blocks.
    /// What this does is simplify the implementation a lot
    ///
    /// - Parameters:
    ///     - none: We depend on values captured by self
    /// - Returns: [Bucket] an array of Bucket instances
    /// - Throws: B2Error if anything goes wrong
    ///
    public var listBuckets: @Sendable (_ parameter: ListBuckets) async throws -> [ListBuckets.Response.Bucket]
    public var listEntriesInDir: @Sendable (_ parameter: ListEntriesInDir) async throws -> [ListEntriesInDir.Response.File]
    public var listComputers: @Sendable (_ parameter: ListComputers) async throws -> [ListComputers.Response.Computer]
    
    /**
     cdeda@backblaze.com
     July 17, 1023
     002d365fdf3dfcc0000000001
     keyName: BackBlazeDemo
     applicationKey: K0025cy1RjM8KO8OmbKPOV2mc9cqQnI
     */
    public var authorizeAccount: @Sendable (_ applicationKeyID: String, _ applicationKey: String) async throws -> Authentication
}

extension DependencyValues {
    public var b2ApiClient: B2ApiClient {
        get { self[B2ApiClient.self] }
        set { self[B2ApiClient.self] = newValue }
    }
}

extension B2ApiClient: DependencyKey {
    public static let liveValue = Self(
        listBuckets: { params in
            do {
                return try await params.urlRequest().fetchResponse(ListBuckets.Response.self).buckets
            } catch {
                Log4swift[Self.self].error("error: \(error)")
                throw error
            }
        },
        listEntriesInDir: { params in
            do {
                return try await params.urlRequest().fetchResponse(ListEntriesInDir.Response.self).files
            } catch {
                Log4swift[Self.self].error("error: \(error)")
                throw error
            }
        },
        listComputers: { params in
            do {
                let computers = try await params.urlRequest().fetchResponse([ListComputers.Response.Computer].self)
                
                return computers.map {
                    Log4swift[Self.self].info("file: \($0)")
                    return $0
                }
                return []
            } catch {
                Log4swift[Self.self].error("error: \(error)")
                throw error
            }
        },
        authorizeAccount: { applicationKeyID, applicationKey in
            do {
                // MARK: - Valid URL? https://api002.backblazeb2.com
                guard let url = URL(string: "https://api002.backblazeb2.com/b2api/v2/b2_authorize_account"),
                      let data = String(applicationKeyID + ":" + applicationKey).data(using: .utf8)
                else { throw ApiError(status: 400, code: "400", message: "failed to init authorizeAccount URL / headers") }
                
                let authHeader = ["Authorization": String("Basic" + data.base64EncodedString())]
                var urlRequest = URLRequest(url: url)
                urlRequest.timeoutInterval = 10.0 // in seconds
                urlRequest.httpMethod = "GET"
                urlRequest.allHTTPHeaderFields = authHeader.appending(NetworkUtilities.defaultBackblazeHeaders)
                return try await urlRequest.fetchResponse(Authentication.self)
            } catch {
                Log4swift[Self.self].error("error: \(error)")
                throw error
            }
        }
        
    )
}

extension B2ApiClient: TestDependencyKey {
    public static let previewValue = Self(
        listBuckets: { _ in
            return []
        },
        listEntriesInDir: { _ in
            return []
        },
        listComputers: { _ in
            return []
        },
        authorizeAccount: { _, _ in
            return .init(
                apiUrl: URL(fileURLWithPath: NSTemporaryDirectory()),
                accountId: "TBD",
                authToken: "TBD"
            )
        }
        
    )
    
    public static let testValue = Self(
        listBuckets: XCTUnimplemented("\(Self.self).listBuckets"),
        listEntriesInDir: XCTUnimplemented("\(Self.self).listEntriesInDir"),
        listComputers: XCTUnimplemented("\(Self.self).listComputers"),
        authorizeAccount: XCTUnimplemented("\(Self.self).authorizeAccount")
    )
}
