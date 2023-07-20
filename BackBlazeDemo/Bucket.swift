import SwiftUI
import ComposableArchitecture
import Tagged
import B2Api

// MARK: - View
struct BucketView: View {
    let store: StoreOf<BucketReducer>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                HStack {
                    Image(systemName: "externaldrive.fill")
                        .font(.title)
                    Text(viewStore.bucket.bucketName)
                        .frame(alignment: .leading)
                        .multilineTextAlignment(.leading)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.some(.footnote))
                        .fontWeight(.some(.bold))
                        .foregroundColor(.secondary.opacity(0.50))
                }
            }
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

