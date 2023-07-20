import SwiftUI
import ComposableArchitecture
import B2Api

// MARK: - View
struct BucketListView: View {
    let store: StoreOf<BucketListReducer>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationStack {
                List {
                    ForEachStore(store.scope(
                        state: \.buckets,
                        action: BucketListReducer.Action.bucket
                    )) { childStore in
                        BucketView(store: childStore)
                    }
                }
                .navigationTitle("Buckets")
                .onAppear {
                    viewStore.send(.onAppear)
                }
            }
        }
    }
}

// MARK: - Reducer
struct BucketListReducer: ReducerProtocol {
    struct State: Equatable {
        var authentication: Authentication
        var buckets:  IdentifiedArrayOf<BucketReducer.State> = []
    }
    
    enum Action: Equatable {
        case onAppear
        case listBucketsDidEnd(TaskResult<[ListBuckets.Response.Bucket]>)
        case bucket(BucketReducer.State.ID, BucketReducer.Action)
    }
    @Dependency(\.b2Api) var b2Api
    
    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                let request = ListBuckets(auth: state.authentication)
                return .task {
                    await .listBucketsDidEnd(TaskResult {
                        try await b2ApiClient.listBuckets(request)
                    })
                }
                
            case let .listBucketsDidEnd(.success(value)):
                Log4swift[Self.self].info("listBucketsDidEnd: \(value)")
                state.buckets = .init(uniqueElements: value.map({
                    .init(id: .init(), bucket: $0)
                }))
                return .none
                
            case let .listBucketsDidEnd(.failure(error)):
                Log4swift[Self.self].info("listBucketsDidEnd: '\(error)'")
                state.inFlight = false
                return .none
                
            case let .bucket(id, action):
                return .none
            }
        }
        .forEach(\.buckets, action: /Action.bucket) {
            BucketReducer()
        }
    }
}

// MARK: - Preview
struct BucketListView_Previews: PreviewProvider {
    static let auth = Authentication(
        apiUrl : URL(string: "https://api005.backblazeb2.com")!,
        accountId : "7bc15b3584db",
        authToken : "4_0057bc15b3584db0000000001_01adc197_04b9bd_acct_HX4yoUGNMV1oQ_d9rk4tqk9xL5w="
    )
    
    static var previews: some View {
        BucketListView(store: .init(
            initialState: .init(authentication: auth),
            reducer: BucketListReducer.init,
            withDependencies: { $0.b2ApiClient = .liveValue }
            //            ,
            //            withDependencies: {
            //                $0.b2Api = .liveValue
            //                $0.b2Api.listBuckets = { _ in
            ////                    try await Task.sleep(for: .seconds(1))
            //                    return (1...10).map { num in
            //                            .init(
            //                                accountId: "\(num))",
            //                                bucketName: "Bucket \(num)",
            //                                bucketId: "\(num))",
            //                                bucketType: "\(num)"
            //                            )
            //                    }
            //                }
            //            }
        ))
    }
}

