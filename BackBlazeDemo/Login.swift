import SwiftUI
import ComposableArchitecture
import B2Api
import Log4swift

/// There are a couple features one could add here:
/// 1. textfield focus:
///    - if user is focused ont he applicationKeyID and submits it when the value is non-empty (trimming whitespaces and newlines,
///      focus to textfield below)
/// 2. button disabled unless both textfiields are n on empty trimming whitespaaces and newlines
/// 3. animated background like backblaze website would be very nice
/// 4. maybe hidden or even secure textfields because what the user enters is very critical information
/// 5. Login - timeout after 5x failures or something, maybe only notify once they've failed 3 times start the countdown
/// 6. Login - timeout, maybe 10,30,60 seconds show an alert timing out.
/// 7. Login - block anymore than one tap while an action is inflight


// MARK: - View
struct LoginView: View {
    let store: StoreOf<LoginReducer>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .leading) {
                Rectangle()
                    .fill(.clear)
                    .frame(height: 100)
                Text("Welcome Back")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.red)
                    .font(.largeTitle)
                    .padding([.bottom])

                Text("Sign In")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.primary)
                    .font(.title)

                TextField("ApplicationKeyID", text: viewStore.binding(\.$applicationKeyID))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.secondary, lineWidth: 1)
                    )
                    .padding([.horizontal], 1)

                TextField("ApplicationKeyID", text: viewStore.binding(\.$applicationKey))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.secondary, lineWidth: 1)
                    )
                    .padding([.horizontal], 1)

                Button {
                    viewStore.send(.loginButtonTapped)
                } label: {
                    Text("Login")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .tint(.red)
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.roundedRectangle(radius: 25))
                .frame(maxWidth: .infinity, alignment: .leading)
                .overlay(
                    ProgressView()
                        .scaleEffect(1.6, anchor: .center)
                        .frame(width: 16, height: 16)
                        .progressViewStyle(.circular)
                        .opacity(viewStore.inFlight ? 1.0 : 0.0)
                    , alignment: .leading
                )

                Spacer()
            }
            .frame(maxWidth: 220)
            .alert(store: store.scope(state: \.$alert, action: LoginReducer.Action.alert))
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}

// MARK: - Reducer
struct LoginReducer: ReducerProtocol {
    struct State: Equatable {
        @BindingState var applicationKeyID: String = ""
        @BindingState var applicationKey: String = ""
        @PresentationState var alert: AlertState<AlertAction>?
        // TODO: Probably put a timeout after 5x failures or something
        // maybe only notify once they've failed 3 times start the countdown
        var autoLogin = false
        var inFlight = false

        var loginIsDisabled: Bool {
            applicationKeyID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            applicationKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }

        init() {
            self.applicationKeyID = UserDefaults.standard.string(forKey: "applicationKeyID") ?? ""
            self.applicationKey = UserDefaults.standard.string(forKey: "applicationKey") ?? ""
            self.autoLogin = UserDefaults.standard.bool(forKey: "autoLogin") ?? false
        }
    }

    enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case loginButtonTapped
        case authorizeAccountDidEnd(TaskResult<Authentication>)
        case alert(PresentationAction<AlertAction>)
        case delegate(DelegateAction)
    }

    @Dependency(\.b2Api) var b2Api

    var body: some ReducerProtocolOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .onAppear:
                return state.autoLogin ? .send(.loginButtonTapped) : .none

            case .loginButtonTapped:
                let request = AuthorizeAccount.Request(
                    applicationKeyId: state.applicationKeyID,
                    applicationKey: state.applicationKey
                )
                state.autoLogin = false
                state.inFlight = true
                return .task {
                    await .authorizeAccountDidEnd(TaskResult {
                        let response = try await b2Api.authorizeAccount(request)
                        return response.authentication
                    })
                }

            case let .alert(action):
                switch action {
                case .dismiss:
                    state.alert = nil
                    return .none
                }
                return .none

            case .delegate:
                return .none

            case let .authorizeAccountDidEnd(.success(value)):
                Log4swift[Self.self].info("authorizeAccountDidEnd: \(value)")
                state.inFlight = true
                return .send(.delegate(.loginSuccessfull(value)))

            case let .authorizeAccountDidEnd(.failure(error)):
                Log4swift[Self.self].info("authorizeAccountDidEnd: '\(error)'")
                state.inFlight = true
                state.alert = .invalidParameters
                return .none

            }
        }
    }
}

extension LoginReducer {
    enum DelegateAction: Equatable {
        case loginSuccessfull(Authentication)
    }
}

extension LoginReducer {
    enum AlertAction: Equatable { }
}

extension AlertState where Action == LoginReducer.AlertAction {
    static let invalidParameters = Self(
        title: {
            TextState("Invalid Parameters")
        },
        actions: {
            ButtonState {
                TextState("Dismiss")
            }
        },
        message: {
            TextState("Please use a valid pair of an application key ID and an application key.")
        }
    )
}

// MARK: - Preview
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            LoginView(store: .init(
                initialState: .init(),
                reducer: LoginReducer.init
            ))
            // TODO: - you may edit the b2Api.authorizeAccount endpoint preview value
            // to behave differently if you'd like
        }
    }
}

