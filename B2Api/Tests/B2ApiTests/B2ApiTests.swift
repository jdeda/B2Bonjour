import SystemConfiguration
import ComposableArchitecture
import Log4swift
import XCTest
@testable import B2Api

@MainActor
final class B2ApiTests: XCTestCase {
  /// these will prop expire but cool for testing
  let auth = Authentication(
    apiUrl: URL(string: "https://api002.backblazeb2.com")!,
    accountId: "d365fdf3dfcc",
    authToken: "5_002-34fa50f0-cd6e-11ed-bf03-cfbea63e1e16_1680010879509_01ab4825_YoCWg7_RTorssR2SLn3wdZk6Z8UzuVdC24="
  )
  
  //      - authToken : "5_002-b86daa80-cf0e-11ed-939b-75e395581e99_1680189777716_01ab53ca_mMXxWp_l1ISYayUWoEdVC-NcP3ZP4Z55po="
  
  override func setUp() async throws {
    Log4swiftConfig.configureLogs(defaultLogFile: nil, lock: "IDDLogLock")
  }
  
  /// given an authentication, copy paste this from the app or postman
  /// run the b2ApiClient.listBuckets
  func testListBuckets() async throws {
    _ = try await withDependencies {
      // we want to test the live implementation for this test
      $0.b2ApiClient = .liveValue
    } operation: {
      @Dependency(\.b2ApiClient) var b2ApiClient
      
      let param = ListBuckets(auth: auth)
      let buckets = try await b2ApiClient.listBuckets(param)
        .map { bucket in
          // feel free to compose more work
          Log4swift[Self.self].info("bucket: \(bucket)")
          return bucket
        }
      Log4swift[Self.self].info("buckets: \(buckets)")
      
      XCTAssertEqual(buckets.count, 2)
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
      
      let param = ListBuckets(auth: auth)
      let buckets = try await b2ApiClient.listBuckets(param)
      NSLog("buckets: \(buckets)")
      
      let allFolders = try? await buckets.asyncMap { bucket in
        let param = ListEntriesInDir(auth: auth, bucketId: bucket.bucketId, startFileName: nil, shouldShowFileVersions: false, shouldReturnFolders: true)
        let dirEntries = try await b2ApiClient.listEntriesInDir(param)
        return dirEntries
      }
      Log4swift[Self.self].info("allFolders: \(allFolders)")
      
      XCTAssertEqual(buckets.count, 2)
    }
  }
  
  /// given an authentication, copy paste this from the app or postman
  /// run the b2ApiClient.listComputers
  func testListComputers() async throws {
    _ = try await withDependencies {
      // we want to test the live implementation for this test
      $0.b2ApiClient = .liveValue
    } operation: {
      @Dependency(\.b2ApiClient) var b2ApiClient
      
      let auth = Authentication(
        apiUrl: URL(string: "https://ca002.backblaze.com")!,
        accountId: "d365fdf3dfcc",
        authToken: "5_002-4042a810-cf10-11ed-80a7-65550f728124_1680190431643_01ab53d5_8Sdy0F_J1FBESluOxyx-zLAjVSj4xZlAEU="
      )
      let param = ListComputers(auth: auth, clusterNum: "002", deviceId: "ios_device")
      let computers = try await b2ApiClient.listComputers(param)
        .map { computer in
          Log4swift[Self.self].info("computer: \(computer)")
          return computer
        }
      Log4swift[Self.self].info("computers: \(computers)")
      
      XCTAssertEqual(computers.count, 11)
    }
  }
  
  func testAuthorizeAccount() async throws {
    _ = try await withDependencies {
      $0.b2ApiClient = .liveValue
    } operation: {
      @Dependency(\.b2ApiClient) var b2ApiClient
      
      let param = AuthorizeAccount.Request(
        applicationKeyId: "0058da1b241b82e13d1cf37aed6af6685b46596eaa",
        applicationKey: "K005EueuAu9rB/CATltSWhBVJfuKT5A"
      )
      let response = try await b2ApiClient.authorizeAccount(param)
      
      XCTAssertTrue(response.accountId == "foo")
      XCTAssertTrue(response.authorizationToken == "foo")
      XCTAssertTrue(response.apiUrl == "foo")
    }
  }
}
