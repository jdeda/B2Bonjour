import SwiftUI
import B2Api

@main
struct BackBlazeDemoApp: App {
  var body: some Scene {
    WindowGroup {
      AppView(store: .init(
        initialState: .login(.init()),
        reducer: AppReducer.init
      ))
    }
  }
}
