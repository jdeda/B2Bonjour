import SwiftUI
import ComposableArchitecture

// MARK: - View
struct StorageView: View {
  let store: StoreOf<StorageReducer>
  
  var body: some View {
    WithViewStore(store) { viewStore in
      Text("StorageView")
    }
  }
}

// MARK: - Reducer
struct StorageReducer: ReducerProtocol {
  struct State: Equatable {
    
  }
  
  enum Action: Equatable {
    
  }
  
  var body: some ReducerProtocolOf<Self> {
    Reduce { state, action in
      switch action {
        
      }
    }
  }
}

// MARK: - Preview
struct StorageView_Previews: PreviewProvider {
  static var previews: some View {
    StorageView(store: .init(
      initialState: .init(),
      reducer: StorageReducer.init
    ))
  }
}

