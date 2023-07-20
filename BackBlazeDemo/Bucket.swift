import SwiftUI
import ComposableArchitecture
import Tagged
import B2Api

// MARK: - View
struct BucketView: View {
    let store: StoreOf<BucketReducer>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            Form {
                DisclosureGroup {
                    Section {
                        Text(viewStore.bucket.bucketName)
                    } header: {
                        Text("Bucket Name")
                    }
                    Section {
                        Text(viewStore.bucket.bucketId)
                    } header: {
                        Text("Bucket ID")
                    }

                    Section {
                        Text(viewStore.bucket.bucketType)
                    } header: {
                        Text("Bucket Type")
                    }

                    Section {
                        Text(viewStore.bucket.accountId)
                    } header: {
                        Text("Account ID")
                    }
                } label: {
                    Text("Metadata")
                }

                Section {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.secondary)
                        .frame(width: 200, height: 200)
                } header: {
                    Text("ok")
                }

            }
            
            .navigationTitle("Bucket")
        }
    }
}

// MARK: - Reducer
struct BucketReducer: ReducerProtocol {
    struct State: Equatable, Identifiable {
        typealias ID = Tagged<Self, UUID>
        
        let id: ID
        var bucket: ListBuckets.Response.Bucket
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
struct BucketView_Previews: PreviewProvider {
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
                    )
                ),
                reducer: BucketReducer.init
            ))
        }
    }
}

