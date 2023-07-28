import SystemConfiguration
import ComposableArchitecture
import Log4swift
import XCTest
@testable import B2Api

// allows us to test as a particular backblaze user
// MARK: This will intefere with asserts because each user may have different
// buckets and different content in each bucket there should be a shared bucket or account.
enum User {
    case kdeda
    case jdeda

    var bucketName: String {
        switch self {
        case .kdeda: return "deda-inc"
        case .jdeda: return "BackBlazeDemoBucket-f61febdb-cd17-45df-9685-a7c399150052"
        }
    }
}

@MainActor
final class B2ApiTests: XCTestCase {
    private static var auth = Authentication.unarchive("authorizeAccount")
    private static var user: User = .jdeda
    var logInit = false
    
    enum TestError: Error { case failure(String) }
    
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

            func response_1() async throws -> Authentication {
                //  cdeda@backblaze.com
                //  July 17, 1023
                //  002d365fdf3dfcc0000000001
                //  keyName: BackBlazeDemo
                //  applicationKey: K0025cy1RjM8KO8OmbKPOV2mc9cqQnI

                try await b2ApiClient.authorizeAccount(
                    "002d365fdf3dfcc0000000001",
                    "K0025cy1RjM8KO8OmbKPOV2mc9cqQnI"
                )
            }

            func response_2() async throws -> Authentication {
                // Jesse Deda
                try await b2ApiClient.authorizeAccount(
                    "0057bc15b3584db0000000001",
                    "K005EueuAu9rB/CATltSWhBVJfuKT5A"
                )
            }

            let authentication = try await Self.user == .kdeda ? response_1() : response_2()
            Self.auth = Authentication.unarchive("authorizeAccount")
            Log4swift[Self.self].info("Self.auth: \(Self.auth)")
            // Self.auth = response_1
        }
    }
    
    func testGetUploadFileURL() async throws {
        _ = try await withDependencies {
            $0.b2ApiClient = .liveValue
        } operation: {
            @Dependency(\.b2ApiClient) var b2ApiClient
            
            // Get first bucket id.
            guard let bucketID = try await b2ApiClient.listBuckets(ListBuckets(auth: Self.auth))
                .first?.bucketId
            else {
                XCTFail("did not get a bucketID when one should have been found")
                return
            }
            
            let response1: GetUploadURL.Response = try await {
                let params = GetUploadURL(auth: Self.auth, request: GetUploadURL.Request(bucketId: bucketID))
                let response = try await b2ApiClient.getUploadURL(params)

                return response
            }()
            Log4swift[Self.self].info("response: \(response1)")

            let response2: GetUploadURL.Response = try await {
                let params = GetUploadURL(auth: Self.auth, request: GetUploadURL.Request(bucketId: bucketID))
                let response = try await b2ApiClient.getUploadURL(params)

                return response
            }()
            Log4swift[Self.self].info("response: \(response2)")

            // TODO: How to assert on this?
        }
    }
  
    func testUploadFile() async throws {
        _ = try await withDependencies {
            $0.b2ApiClient = .liveValue
        } operation: {
            @Dependency(\.b2ApiClient) var b2ApiClient
            
            // Get first bucket id.
            let bucketName = Self.user.bucketName
            let buckets = try await b2ApiClient.listBuckets(ListBuckets(auth: Self.auth))
            guard let bucketID = buckets.first(where: { $0.bucketName == bucketName })?.bucketId
            else {
                XCTFail("did not get a bucketID when one should have been found")
                return
            }
            
            // Get the upload URL
            let uploadURL: GetUploadURL.Response = try await {
                let params = GetUploadURL(auth: Self.auth, request: GetUploadURL.Request(bucketId: bucketID))
                let response = try await b2ApiClient.getUploadURL(params)

                return response
            }()

            // Attempt to upload the file.
            let fileName = "Test 123"
            let fileData = fileName.data(using: .utf8) ?? Data()
            let params = UploadFile(authorizationToken: uploadURL.authorizationToken, uploadURL: uploadURL.uploadUrl, fileName: fileName, fileData: fileData)
            let response = try await b2ApiClient.uploadFile(params)

            Log4swift[Self.self].info("response: \(response)")
        }
    }
    
    func testListFileNames() async throws {
        _ = try await withDependencies {
            $0.b2ApiClient = .liveValue
        } operation: {
            @Dependency(\.b2ApiClient) var b2ApiClient
            
            let bucketID: String = try await {
                let param = ListBuckets(auth: Self.auth)
                guard let bucketID = try await b2ApiClient.listBuckets(param).first?.bucketId
                else {
                    throw TestError.failure("did not get a bucketID when one should have been found")
                }
                return bucketID
            }()
            
            let params = ListFileNames(auth: Self.auth, request: .init(bucketId: bucketID))
            let response = try await b2ApiClient.listFileNames(params)
            Log4swift[Self.self].info("bucketID: \(bucketID)")
        }
    }
    
}

/// What we would like is to request this auth, then use it in every request...
