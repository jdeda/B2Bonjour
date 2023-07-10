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
        TextField("untitled todo", text: viewStore.binding(
          get: \.todo.description,
          send: { .descriptionEdited($0) }
        ))
          .autocorrectionDisabled(true)
          .autocapitalization(.none)
      }
      .strikethrough(viewStore.todo.isComplete)
      .foregroundColor(viewStore.todo.isComplete ? .secondary : .primary)
      .foregroundColor(viewStore.todo.description.isEmpty ? .secondary : .primary)
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
    var todo: Todo
  }
  
  enum Action: Equatable {
    case isCompleteToggled
    case descriptionEdited(String)
    case delegate(DelegateAction)
  }
  
  var body: some ReducerProtocolOf<Self> {
    Reduce { state, action in
      switch action {
      case .isCompleteToggled:
        state.todo.isComplete.toggle()
        return .none
        
      case let .descriptionEdited(description):
        state.todo.description = description
        return .none
        
      case .delegate:
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
