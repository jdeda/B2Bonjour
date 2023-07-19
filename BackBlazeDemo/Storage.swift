import SwiftUI
import ComposableArchitecture
import B2Api

// MARK: - View
struct StorageView: View {
    let store: StoreOf<StorageReducer>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationStack {
                List {
                    ForEach(viewStore.buckets, id: \.bucketId) { bucket in
                        Text(bucket.bucketName)
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
struct StorageReducer: ReducerProtocol {
    struct State: Equatable {
        var authentication: Authentication
        var buckets: [ListBuckets.Response.Bucket] = []
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
                        try await b2ApiClient.listBuckets(request)
                    })
                }
                
            case let .listBucketsDidEnd(.success(value)):
                Log4swift[Self.self].info("listBucketsDidEnd: \(value)")
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
    static let auth = Authentication(
        apiUrl : URL(string: "https://api005.backblazeb2.com")!,
        accountId : "7bc15b3584db",
        authToken : "4_0057bc15b3584db0000000001_01adc197_04b9bd_acct_HX4yoUGNMV1oQ_d9rk4tqk9xL5w="
    )
    
    static var previews: some View {
        StorageView(store: .init(
            initialState: .init(authentication: auth),
            reducer: StorageReducer.init
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

