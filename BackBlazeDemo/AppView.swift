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
                    state: /AppReducer.State.bucketList,
                    action: AppReducer.Action.bucketList,
                    then: BucketListView.init
                )
            }
        }
    }
}

// MARK: - Reducer
struct AppReducer: ReducerProtocol {
    enum State: Equatable {
        case login(LoginReducer.State)
        case bucketList(BucketListReducer.State)
    }
    
    enum Action: Equatable {
        case login(LoginReducer.Action)
        case bucketList(BucketListReducer.Action)
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
                    state = .bucketList(.init(auth: value))
                    return .none
                }
                
            case let .bucketList(action):
                return .none
            }
        }
        .ifCaseLet(/State.login, action: /Action.login) {
            LoginReducer()
        }
        .ifCaseLet(/State.bucketList, action: /Action.bucketList) {
            BucketListReducer()
        }
    }
}

// MARK: - Preview
struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AppView(store: .init(
                initialState: .login(.init()),
                reducer: AppReducer.init,
                withDependencies: {
                    $0.b2ApiClient = .liveValue
                }
            ))
        }
        // TODO: login button doesn't work in previews properly,
        // which may be because of the preview value or something else
    }
}

