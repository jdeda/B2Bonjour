import SwiftUI
import B2Api
import XCTestDynamicOverlay

@main
struct BackBlazeDemoApp: App {
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
