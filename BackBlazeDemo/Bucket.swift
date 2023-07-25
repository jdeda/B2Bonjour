import SwiftUI
import ComposableArchitecture
import Tagged
import B2Api

// MARK: - View
struct BucketView: View {
    let store: StoreOf<BucketReducer>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                ForEach(viewStore.elements, id: \.self) { element in
                    VStack(alignment: .leading) {
                        HStack {
                            Image(systemName: "doc.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25, height: 25)
                                .clipped()
                            Text(element)
                            Spacer()
                            NavigationLinkIcon()
                        }
                        Divider()
                    }
                    Spacer()
                }
                .padding([.horizontal])
            }
            .navigationTitle("Bucket")
            .searchable(text: .constant(""))
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button {
                            
                        } label: {
                            Text("Metadata")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
                
                ToolbarItemGroup(placement: .bottomBar) {
                    HStack {
                        Label("Recent", systemImage: "clock.fill")
                            .labelStyle(CustomLabelStyle())
                            .font(.subheadline)
                        Spacer()
                        Label("Shared", systemImage: "folder.fill.badge.person.crop")
                            .labelStyle(CustomLabelStyle())
                            .font(.subheadline)
                        Spacer()
                        Label("Browse", systemImage: "folder.fill")
                            .labelStyle(CustomLabelStyle())
                            .font(.subheadline)
                        Spacer()
                        Label("Metadata", systemImage: "info.square.fill")
                            .labelStyle(CustomLabelStyle())
                            .font(.subheadline)
                    }
                }

                
//                ToolbarItemGroup(placement: .bottomBar) {
//                    Text("\(viewStore.elements.count) Files")
//                }
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
        var elements: [String] = (1...50).map({ "File \($0)" })
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


struct CustomLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            configuration.icon
            configuration.title
        }
    }
}
