import SwiftUI
import ComposableArchitecture
import B2Api

// MARK: - View
struct AppView: View {
  let store: StoreOf<AppReducer>
  
  var body: some View {
    WithViewStore(store) { viewStore in
      NavigationStack {
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
          
          TextField("ApplicationKey", text: viewStore.binding(\.$applicationKey))
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
        .alert(store: store.scope(state: \.$alert, action: AppReducer.Action.alert))
      }
    }
  }
}

// MARK: - Reducer
struct AppReducer: ReducerProtocol {
  struct State: Equatable {
    @BindingState var applicationKeyID: String = ""
    @BindingState var applicationKey: String = ""
    @PresentationState var alert: AlertState<Never>?
  }
  
  enum Action: Equatable, BindableAction {
    case binding(BindingAction<State>)
    case loginButtonTapped
    case alert(PresentationAction<Never>)
  }
  
  @Dependency(\.b2Api) var b2Api
  
  var body: some ReducerProtocolOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding:
        return .none
        
      case .loginButtonTapped:
        state.alert = AlertState(
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
        return .none
        
      case .alert:
        return .none
      }
    }
  }
}

// MARK: - Preview
struct AppView_Previews: PreviewProvider {
  static var previews: some View {
    AppView(store: .init(
      initialState: .init(),
      reducer: AppReducer.init
    ))
  }
}

