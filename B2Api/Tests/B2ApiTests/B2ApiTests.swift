import SystemConfiguration
import ComposableArchitecture
import Log4swift
import XCTest
@testable import B2Api

@MainActor
final class B2ApiTests: XCTestCase {
    private static var auth = Authentication.unarchive("authorizeAccount")

    var logInit = false
    
    override func setUp() async throws {
        guard !logInit
        else {
            // log to console, configure it once
            logInit = true
            LoggingSystem.bootstrap { label in
                ConsoleHandler(label: label)
            }
            return
        }
    }
    
    /// given an authentication, copy paste this from the app or postman
    /// run the b2ApiClient.listBuckets
    func testListBuckets() async throws {
        _ = try await withDependencies {
            // we want to test the live implementation for this test
            $0.b2ApiClient = .liveValue
        } operation: {
            @Dependency(\.b2ApiClient) var b2ApiClient
            
            let param = ListBuckets(auth: Self.auth)
            
            let buckets = try await b2ApiClient.listBuckets(param)
                .map { bucket in
                    // feel free to compose more work
                    Log4swift[Self.self].info("bucket: \(bucket)")
                    return bucket
                }
            Log4swift[Self.self].info("buckets: \(buckets)")
            
            XCTAssertEqual(buckets.count, 3)
        }
    }
    
    /// given an authentication, copy paste this from the app or postman
    /// run the b2ApiClient.listBuckets and listEntriesInDir for each of those buckets
    func testListEntriesInDir() async throws {
        _ = try await withDependencies {
            // we want to test the live implementation for this test
            $0.b2ApiClient = .liveValue
        } operation: {
            @Dependency(\.b2ApiClient) var b2ApiClient
            
            let param = ListBuckets(auth: Self.auth)
            let buckets = try await b2ApiClient.listBuckets(param)
            Log4swift[Self.self].info("buckets: \(buckets)")
            
            let allFolders = try? await buckets.asyncMap { bucket in
                let param = ListEntriesInDir(auth: Self.auth, bucketId: bucket.bucketId, startFileName: nil, shouldShowFileVersions: false, shouldReturnFolders: true)
                let dirEntries = try await b2ApiClient.listEntriesInDir(param)
                return dirEntries
            }
            Log4swift[Self.self].info("allFolders: \(String(describing: allFolders))")
            
            XCTAssertEqual(buckets.count, 3)
        }
    }
        
    // TODO: Fix this and make it work!
    /// given an authentication, copy paste this from the app or postman
    /// run the b2ApiClient.listComputers
    //    func testListComputers() async throws {
    //        _ = try await withDependencies {
    //            // we want to test the live implementation for this test
    //            $0.b2ApiClient = .liveValue
    //        } operation: {
    //            @Dependency(\.b2ApiClient) var b2ApiClient
    //
    //            let param = ListComputers(auth: Self.auth, clusterNum: "002", deviceId: "ios_device")
    //
    //
    //            let computers = try await b2ApiClient.listComputers(param)
    //                .map { computer in
    //                    Log4swift[Self.self].info("computer: \(computer)")
    //                    return computer
    //                }
    //            Log4swift[Self.self].info("computers: \(computers)")
    //
    //            XCTAssertEqual(computers.count, 11)
    //        }
    //    }
    
    /**
     Run this test first and capture the authorization for use on the other tests
     */
    func testAuthorizeAccount() async throws {
        _ = try await withDependencies {
            $0.b2ApiClient = .liveValue
        } operation: {
            @Dependency(\.b2ApiClient) var b2ApiClient
            
            let response = try await b2ApiClient.authorizeAccount(
                "0057bc15b3584db0000000001",
                "K005EueuAu9rB/CATltSWhBVJfuKT5A"
            )
            
            Log4swift[Self.self].info("response: \(response)")
            Self.auth = try response
        }
    }
}

/// What we would like is to request this auth, then use it in every request...
