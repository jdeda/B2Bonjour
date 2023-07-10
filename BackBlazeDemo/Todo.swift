import SwiftUI
import ComposableArchitecture
import Tagged

// MARK: - View
struct TodoView: View {
  let store: StoreOf<TodoReducer>
  
  var body: some View {
    WithViewStore(store) { viewStore in
      HStack {
        Button {
          viewStore.send(.isCompleteToggled)
        } label: {
          Image(systemName: viewStore.todo.isComplete ? "checkmark.square" : "square")
            .buttonStyle(.plain)
            .accentColor(.primary)
        }
        Spacer()
        TextField("...", text: viewStore.binding(\.$todo.description))
          .autocorrectionDisabled(true)
          .autocapitalization(.none)
      }
      .strikethrough(viewStore.todo.isComplete)
      .foregroundColor(viewStore.todo.isComplete ? .secondary : .primary)
      .swipeActions {
        Button(role: .destructive) {
          viewStore.send(.delegate(.swipedToDelete))
        } label: {
          Image(systemName: "trash")
        }
      }
    }
  }
}

// MARK: - Reducer
struct TodoReducer: ReducerProtocol {
  struct State: Equatable, Identifiable {
    typealias ID = Tagged<Self, UUID>
    
    let id: ID
    @BindingState var todo: Todo
  }
  
  enum Action: Equatable, BindableAction {
    case isCompleteToggled
    case binding(BindingAction<State>)
    case delegate(DelegateAction)
  }
  
  var body: some ReducerProtocolOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .isCompleteToggled:
        state.todo.isComplete.toggle()
        return .none
      case .binding, .delegate:
        return .none
      }
    }
  }
}

extension TodoReducer {
  enum DelegateAction {
    case swipedToDelete
  }
}

// MARK: - Preview
struct TodoView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      List {
        TodoView(store: .init(
          initialState: .init(id: .init(), todo: .mockTodo),
          reducer: TodoReducer.init
        ))
      }
    }
  }
}
