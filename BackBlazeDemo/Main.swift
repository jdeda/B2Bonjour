import SwiftUI
import B2Api
import XCTestDynamicOverlay

@main
struct BackBlazeDemoApp: App {
    init() {
        Log4swift.configure(appName: "BackBlazeDemoApp")
    }
    var body: some Scene {
        WindowGroup {
            if !_XCTIsTesting {
                AppView(store: .init(
                    initialState: .login(.init()),
                    reducer: AppReducer.init
                ))
            }
        }
    }
}
