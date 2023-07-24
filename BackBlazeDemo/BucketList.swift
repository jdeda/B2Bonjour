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
                    ForEach(viewStore.buckets, id: \.bucketId) { bucket in
                        VStack {
                            HStack {
                                Image(systemName: "externaldrive.fill")
                                    .font(.title)
                                Text(bucket.bucketName)
                                    .frame(alignment: .leading)
                                    .multilineTextAlignment(.leading)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.some(.footnote))
                                    .fontWeight(.some(.bold))
                                    .foregroundColor(.secondary.opacity(0.50))
                            }
                        }
                        .onTapGesture {
                            viewStore.send(.rowTapped(bucket))
                        }
                    }
                    
                }
                .navigationTitle("Buckets")
                .onAppear {
                    viewStore.send(.onAppear)
                }
                .navigationDestination(
                    store: store.scope(
                        state: \.$destination,
                        action: BucketListReducer.Action.destination
                    ),
                    state: /BucketListReducer.DestinationReducer.State.bucket,
                    action: BucketListReducer.DestinationReducer.Action.bucket
                ) { childStore in
                    BucketView(store: childStore)
                }
            }
        }
    }
}

// MARK: - Reducer
struct BucketListReducer: ReducerProtocol {
    struct State: Equatable {
        var authentication: Authentication
        var buckets: [ListBuckets.Response.Bucket] = []
        
        @PresentationState var destination: DestinationReducer.State?
    }
    
    enum Action: Equatable {
        case onAppear
        case listBucketsDidEnd(TaskResult<[ListBuckets.Response.Bucket]>)
        case rowTapped(ListBuckets.Response.Bucket)
        case destination(PresentationAction<DestinationReducer.Action>)
    }
    
    @Dependency(\.b2ApiClient) var b2ApiClient
    @Dependency(\.uuid) var uuid
    
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
                state.buckets = value
                state.destination = .bucket(.init(
                    id: .init(rawValue: uuid()),
                    bucket: value.first!
                ))
                return .none
                
            case let .listBucketsDidEnd(.failure(error)):
                Log4swift[Self.self].info("listBucketsDidEnd: '\(error)'")
                return .none
                
            case let .rowTapped(bucket):
                state.destination = .bucket(.init(
                    id: .init(rawValue: uuid()),
                    bucket: bucket
                ))
                return .none
                
            case let .destination(action):
                return .none
            }
        }
        .ifLet(\.$destination, action: /Action.destination) {
            DestinationReducer()
        }
    }
}

// MARK: - Destination
extension BucketListReducer {
    struct DestinationReducer: ReducerProtocol {
        enum State: Equatable {
            case bucket(BucketReducer.State)
        }
        
        enum Action: Equatable {
            case bucket(BucketReducer.Action)
        }
        
        var body: some ReducerProtocolOf<Self> {
            Scope(state: /State.bucket, action: /Action.bucket) {
                BucketReducer()
            }
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

