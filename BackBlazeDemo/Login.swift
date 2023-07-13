import SwiftUI
import ComposableArchitecture
import B2Api

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
        Spacer()
      }
      .frame(maxWidth: 220)
      .alert(store: store.scope(state: \.$alert, action: LoginReducer.Action.alert))
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
    
    var loginIsDisabled: Bool {
      applicationKeyID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
      applicationKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
  }
  
  enum Action: Equatable, BindableAction {
    case binding(BindingAction<State>)
    case loginButtonTapped
    case loginFailure
    case loginSuccess
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
        
      case .loginButtonTapped:
        return .run { [state = state] send in
          guard let _ = try? await b2Api.authorizeAccount(.init(
            applicationKeyId: state.applicationKeyID,
            applicationKey: state.applicationKey
          ))
          else {
            await send(.loginFailure)
            return
          }
          await send(.delegate(.loginSuccessfull)) // well you probably want to take that response...
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
        
      case .loginFailure:
        state.alert = .invalidParameters
        return .none
        
      case .loginSuccess:
        return .send(.delegate(.loginSuccessfull))
      }
    }
  }
}

extension LoginReducer {
  enum DelegateAction: Equatable {
    case loginSuccessfull
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

