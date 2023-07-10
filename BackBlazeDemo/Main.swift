import SwiftUI

@main
struct BackBlazeDemoApp: App {
  var body: some Scene {
    WindowGroup {
      AppView(store: .init(
        initialState: .init(todos: .init(uniqueElements: Todo.mockTodos.map {
          .init(id: .init(), todo: $0)
        })),
        reducer: AppReducer.init
      ))
    }
  }
}
