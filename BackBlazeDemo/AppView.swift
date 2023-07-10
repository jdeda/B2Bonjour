import SwiftUI
import ComposableArchitecture

// MARK: - View
struct AppView: View {
  let store: StoreOf<AppReducer>
  
  var body: some View {
    WithViewStore(store) { viewStore in
      NavigationStack {
        List {
          ForEachStore(store.scope(state: \.todos, action: AppReducer.Action.todo)) { childStore in
            TodoView(store: childStore)
          }
        }
        .navigationTitle("Todos")
        .toolbar {
          ToolbarItem(placement: .primaryAction) {
            Button {
              viewStore.send(.addButtonTapped, animation: .default)
            } label: {
              Image(systemName: "plus")
            }
            .accentColor(.primary)
          }
        }
      }
    }
  }
}

// MARK: - Reducer
struct AppReducer: ReducerProtocol {
  struct State: Equatable {
    var todos: IdentifiedArrayOf<TodoReducer.State>
  }
  
  enum Action: Equatable {
    case addButtonTapped
    case todo(TodoReducer.State.ID, TodoReducer.Action)
  }
  
  @Dependency(\.uuid) var uuid
  
  var body: some ReducerProtocolOf<Self> {
    Reduce { state, action in
      switch action {
      case .addButtonTapped:
        state.todos.append(.init(id: .init(rawValue: uuid()), todo: .init(id: .init())))
        return .none
        
      case let .todo(id, action):
        switch (/TodoReducer.Action.delegate).extract(from: action) {
        case .swipedToDelete:
          state.todos.remove(id: id)
          return .none
        case .none:
          return .none
        }
      }
    }
    .forEach(\.todos, action: /Action.todo) {
      TodoReducer()
    }
  }
}

// MARK: - Preview
struct AppView_Previews: PreviewProvider {
  static var previews: some View {
    AppView(store: .init(
      initialState: .init(todos: .init(uniqueElements: Todo.mockTodos.map {
        .init(id: .init(), todo: $0)
      })),
      reducer: AppReducer.init
    ))
  }
}

