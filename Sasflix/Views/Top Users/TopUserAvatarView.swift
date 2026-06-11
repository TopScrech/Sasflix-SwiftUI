import SwiftUI

struct TopUserAvatarView: View {
    let url: URL?
    
    var body: some View {
        ZStack {
            Circle()
                .fill(.thinMaterial)
            
            Image(systemName: "person.crop.circle.fill")
                .title()
                .secondary()
            
            if let url {
                AsyncImage(url: url, transaction: Transaction(animation: .default)) {
                    if let image = $0.image {
                        image
                            .resizable()
                            .scaledToFill()
                    }
                }
            }
        }
        .frame(width: 44, height: 44)
        .clipShape(.circle)
        .accessibilityHidden(true)
    }
}
