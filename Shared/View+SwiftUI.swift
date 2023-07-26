import SwiftUI

struct NavigationLinkIcon: View {
    var body: some View  {
        Image(systemName: "chevron.right")
            .font(.some(.footnote))
            .fontWeight(.some(.bold))
            .foregroundColor(.secondary.opacity(0.50))
    }
}
