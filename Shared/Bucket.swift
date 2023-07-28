import SwiftUI
import ComposableArchitecture
import Tagged
import B2Api

// MARK: - View
struct BucketView: View {
    let store: StoreOf<BucketReducer>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            TabView {
                BucketFilesView(files: (1...10).map { "File No.\($0)" })
                    .tabItem {
                        Label("Recent", systemImage: "clock.fill")
                            .labelStyle(CustomLabelStyle())
                            .font(.subheadline)
                    }
                
                BucketFilesView(files: (1...5).map { "File No.\($0)" })
                    .tabItem {
                        Label("Shared", systemImage: "folder.fill.badge.person.crop")
                            .labelStyle(CustomLabelStyle())
                            .font(.subheadline)
                    }
                
                BucketFilesView(files: (1...50).map { "File No.\($0)" })
                    .tabItem {
                        Label("Browse", systemImage: "folder.fill")
                            .labelStyle(CustomLabelStyle())
                            .font(.subheadline)
                    }
                
                MetaDataView(bucket: viewStore.bucket)
                    .tabItem {
                        Label("Metadata", systemImage: "info.square.fill")
                            .labelStyle(CustomLabelStyle())
                            .font(.subheadline)
                    }
            }
            .navigationTitle("Bucket")
            .searchable(text: .constant(""))
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button {
                            
                        } label: {
                            Label("Upload Image", systemImage: "camera.fill")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .task {
                await viewStore.send(.task).finish()
            }
        }
    }
}

private struct MetaDataView: View {
    let bucket: ListBuckets.Response.Bucket
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Bucket Name")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 1)
                Text(bucket.bucketName)
                Divider()
            }
            .padding([.horizontal, .vertical])


            VStack(alignment: .leading) {
                Text("Bucket ID")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 1)
                Text(bucket.bucketId)
                Divider()

            }
            .padding([.horizontal, .vertical])

            VStack(alignment: .leading) {
                Text("Bucket Type")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 1)
                Text(bucket.bucketType)
                Divider()

            }
            .padding([.horizontal, .vertical])
        }
    }
}

struct MetaDataView_Previews: PreviewProvider {
    static var previews: some View {
        MetaDataView(bucket: .init(
            accountId: "039240128u43012m0d19d01dm",
            bucketName: "foobar-A0B1-C2D3-E4F5-OPQRSTUVWXYZ",
            bucketId: "20192IUIMXAJSNKDJANS", bucketType: "foobaristic"
        ))
    }
}

struct BucketFilesView: View {
    let files: [String]
    
    var body: some View {
        ScrollView {
            ForEach(files, id: \.self) { element in
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "doc.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                            .clipped()
                        Text(element)
                        Spacer()
//                        NavigationLinkIcon()
                    }
                    Divider()
                }
                Spacer()
            }
            .padding([.horizontal])
        }
    }
}

// MARK: - Reducer
struct BucketReducer: ReducerProtocol {
    struct State: Equatable, Identifiable {
        typealias ID = Tagged<Self, UUID>
        
        let id: ID
        var bucket: ListBuckets.Response.Bucket
        var fileNames: [String] = []
        var auth: Authentication
    }
    
    enum Action: Equatable {
        case task
        case listFileNamesDidEnd(TaskResult<ListFileNames.Response>)

    }
    
    @Dependency(\.b2ApiClient) var b2ApiClient
    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .task:
                return .task { [bucketId = state.bucket.bucketId, auth = state.auth] in
                    await .listFileNamesDidEnd(TaskResult {
                        let params = ListFileNames(auth: auth, request: .init(bucketId: bucketId))
                        return try await b2ApiClient.listFileNames(params)
                    })
                }
            case let .listFileNamesDidEnd(.success(response)):
                state.fileNames = response.files.map(\.fileName)
                return .none
                
            case let .listFileNamesDidEnd(.failure(error)):
                return .none
            }
        }
    }
}

fileprivate struct CustomLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            configuration.icon
            configuration.title
        }
    }
}

// MARK: - Preview
struct BucketView_Previews: PreviewProvider {
    static let auth = Authentication(
        apiUrl : URL(string: "https://api005.backblazeb2.com")!,
        accountId : "7bc15b3584db",
        authToken : "4_0057bc15b3584db0000000001_01adc197_04b9bd_acct_HX4yoUGNMV1oQ_d9rk4tqk9xL5w="
    )
    
    static var previews: some View {
        
        NavigationStack {
            BucketView(store: .init(
                initialState: .init(
                    id: .init(),
                    bucket: .init(
                        accountId: "123",
                        bucketName:"foo",
                        bucketId: "123foo",
                        bucketType: "footype"
                    ),
                    auth: auth
                ),
                reducer: BucketReducer.init
            ))
        }
    }
}
