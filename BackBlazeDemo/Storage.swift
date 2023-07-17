import SwiftUI
import ComposableArchitecture
import B2Api

// MARK: - View
struct StorageView: View {
    let store: StoreOf<StorageReducer>

    var body: some View {
        WithViewStore(store) { viewStore in
            Text("StorageView")
                .onAppear {
                    viewStore.send(.onAppear)
                }
        }
    }
}

// MARK: - Reducer
struct StorageReducer: ReducerProtocol {
    struct State: Equatable {
        var authentication: Authentication
    }

    enum Action: Equatable {
        case onAppear
        case listBucketsDidEnd(TaskResult<[ListBuckets.Response.Bucket]>)
    }
    @Dependency(\.b2Api) var b2Api

    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                let request = ListBuckets.init(auth: state.authentication)

                return .task {
                    await .listBucketsDidEnd(TaskResult {
                        try await b2Api.listBuckets(request)
                    })
                }

            case let .listBucketsDidEnd(.success(value)):
                Log4swift[Self.self].info("listBucketsDidEnd: \(value)")
                return .none

            case let .listBucketsDidEnd(.failure(error)):
                Log4swift[Self.self].info("listBucketsDidEnd: '\(error)'")
                return .none
            }
        }
    }
}

// MARK: - Preview
struct StorageView_Previews: PreviewProvider {
    static var previews: some View {
        StorageView(store: .init(
            initialState: .init(authentication: .empty),
            reducer: StorageReducer.init
        ))
    }
}

