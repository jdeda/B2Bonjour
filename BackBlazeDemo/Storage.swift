import SwiftUI
import ComposableArchitecture
import B2Api

// MARK: - View
struct StorageView: View {
    let store: StoreOf<StorageReducer>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                Text("\(viewStore.buckets.count) found, inFlight: \(viewStore.inFlight ? "true" : "false")")
                Text("\(viewStore.buckets.description)")
                Text("StorageView")
            }
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
        var inFlight = false
        var buckets: [ListBuckets.Response.Bucket] = []
    }

    enum Action: Equatable {
        case onAppear
        case listBucketsDidEnd(TaskResult<[ListBuckets.Response.Bucket]>)
    }
    @Dependency(\.b2ApiClient) var b2ApiClient

    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                let request = ListBuckets.init(auth: state.authentication)

                state.inFlight = true
                return .task {
                    await .listBucketsDidEnd(TaskResult {
                        try await b2ApiClient.listBuckets(request)
                    })
                }

            case let .listBucketsDidEnd(.success(value)):
                Log4swift[Self.self].info("listBucketsDidEnd: \(value)")
                state.inFlight = false
                state.buckets = value
                return .none

            case let .listBucketsDidEnd(.failure(error)):
                Log4swift[Self.self].info("listBucketsDidEnd: '\(error)'")
                state.inFlight = false
                return .none
            }
        }
    }
}

// MARK: - Preview
struct StorageView_Previews: PreviewProvider {
    static var previews: some View {
        StorageView(store: .init(
            initialState: .init(authentication: Authentication.unarchive("authorizeAccount")),
            reducer: StorageReducer.init
        ))
    }
}

