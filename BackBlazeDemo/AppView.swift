import SwiftUI
import ComposableArchitecture

// MARK: - View
struct AppView: View {
  let store: StoreOf<AppReducer>
  
  var body: some View {
    WithViewStore(store) { viewStore in
      SwitchStore(store) {
        CaseLet(
          state: /AppReducer.State.login,
          action: AppReducer.Action.login,
          then: LoginView.init
        )
        CaseLet(
          state: /AppReducer.State.storage,
          action: AppReducer.Action.storage,
          then: StorageView.init
        )
      }
    }
  }
}

// MARK: - Reducer
struct AppReducer: ReducerProtocol {
  enum State: Equatable {
    case login(LoginReducer.State)
    case storage(StorageReducer.State)
  }
  
  enum Action: Equatable {
    case login(LoginReducer.Action)
    case storage(StorageReducer.Action)
  }
  
  var body: some ReducerProtocolOf<Self> {
    Reduce { state, action in
      switch action {
      case let .login(action):
        let action = (/LoginReducer.Action.delegate).extract(from: action)
        switch action {
        case .none:
          return .none

        case let .loginSuccessfull(value):
          state = .storage(.init(authentication: value))
          return .none
        }
        
      case let .storage(action):
        return .none
      }
    }
    .ifCaseLet(/State.login, action: /Action.login) {
      LoginReducer()
    }
    .ifCaseLet(/State.storage, action: /Action.storage) {
      StorageReducer()
    }
  }
}

// MARK: - Preview
struct AppView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      AppView(store: .init(
        initialState: .login(.init()),
        reducer: AppReducer.init
      ))
    }
    // TODO: login button doesn't work in previews properly,
    // which may be because of the preview value or something else
  }
}

