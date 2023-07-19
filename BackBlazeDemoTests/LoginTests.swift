import XCTest
import ComposableArchitecture
import Dependencies

@testable import BackBlazeDemo
import B2Api

@MainActor
final class LoginTests: XCTestCase {
    
    func testBindingSetApplicationKeyID() async {
        let store = TestStore(
            initialState: LoginReducer.State(),
            reducer: LoginReducer.init,
            withDependencies: {
                $0.b2ApiClient = .testValue
            }
        )
        
        await store.send(.binding(.set(\.$applicationKeyID, "f"))) {
            $0.applicationKeyID = "f"
        }
        await store.send(.binding(.set(\.$applicationKeyID, "fo"))) {
            $0.applicationKeyID = "fo"
        }
        await store.send(.binding(.set(\.$applicationKeyID, "foo"))) {
            $0.applicationKeyID = "foo"
        }
        await store.send(.binding(.set(\.$applicationKeyID, "fo"))) {
            $0.applicationKeyID = "fo"
        }
        await store.send(.binding(.set(\.$applicationKeyID, ""))) {
            $0.applicationKeyID = ""
        }
    }
    
    func testBindingSetApplicationKey() async {
        let store = TestStore(
            initialState: LoginReducer.State(),
            reducer: LoginReducer.init,
            withDependencies: {
                $0.b2ApiClient = .testValue
            }
        )
        
        await store.send(.binding(.set(\.$applicationKey, "f"))) {
            $0.applicationKey = "f"
        }
        await store.send(.binding(.set(\.$applicationKey, "fo"))) {
            $0.applicationKey = "fo"
        }
        await store.send(.binding(.set(\.$applicationKey, "foo"))) {
            $0.applicationKey = "foo"
        }
        await store.send(.binding(.set(\.$applicationKey, "fo"))) {
            $0.applicationKey = "fo"
        }
        await store.send(.binding(.set(\.$applicationKey, ""))) {
            $0.applicationKey = ""
        }
    }
    
    func testLoginButtonTapped() async {
        enum LocalError: Error, Equatable { case failure }
        
        let auth = Authentication(apiUrl: URL(string: "biggiesmalls")!, accountId: "biggiesmalls", authToken: "biggiesmalls")
        let clock = TestClock()
        let store = TestStore(
            initialState: LoginReducer.State(),
            reducer: LoginReducer.init,
            withDependencies: {
                $0.b2ApiClient = .testValue
                $0.b2Api.authorizeAccount = { applicationKeyId, applicationKey in
                    try await clock.sleep(for: .seconds(1))
                    if applicationKeyId == "biggie" && applicationKey == "smalls" {
                        return auth
                    }
                    throw LocalError.failure
                }
            }
        )
        
        // Try logging in with invalid values, then dismiss it.
        enum LocalTestError: Error, Equatable { case failure }
        let e = LocalTestError.failure
        await store.send(.loginButtonTapped)
        await clock.advance(by: .seconds(1))
        await store.receive(.authorizeAccountDidEnd(.failure(e)), timeout: .seconds(2)) {
            $0.alert = .invalidParameters
        }
        await store.send(.alert(.dismiss)) {
            $0.alert = nil
        }
        
        // Try again but with different invalid values, then dismiss it.
        await store.send(.binding(.set(\.$applicationKeyID, "foo"))) {
            $0.applicationKeyID = "foo"
        }
        await store.send(.loginButtonTapped)
        await clock.advance(by: .seconds(1))
        await store.receive(.authorizeAccountDidEnd(.failure(e)), timeout: .seconds(2)) {
            $0.alert = .invalidParameters
        }
        await store.send(.alert(.dismiss)) {
            $0.alert = nil
        }
        
        // Try again but with different invalid values
        await store.send(.binding(.set(\.$applicationKey, "bar"))) {
            $0.applicationKey = "bar"
        }
        await store.send(.loginButtonTapped)
        await clock.advance(by: .seconds(1))
        await store.receive(.authorizeAccountDidEnd(.failure(e)), timeout: .seconds(2)) {
            $0.alert = .invalidParameters
        }
        await store.send(.alert(.dismiss)) {
            $0.alert = nil
        }
        
        await store.finish(timeout: .seconds(2))
        
        // Try with our made-up valid values!
        await store.send(.binding(.set(\.$applicationKeyID, "biggie"))) {
            $0.applicationKeyID = "biggie"
        }
        await store.send(.binding(.set(\.$applicationKey, "smalls"))) {
            $0.applicationKey = "smalls"
        }
        await store.send(.loginButtonTapped)
        await clock.advance(by: .seconds(1))
        await store.receive(.delegate(.loginSuccessfull(auth)), timeout: .seconds(2))
    }
}

