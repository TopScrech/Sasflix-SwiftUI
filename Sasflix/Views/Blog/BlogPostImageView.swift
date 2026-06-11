import SwiftUI

struct BlogPostImageView: View {
    let url: URL?
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.thinMaterial)
            
            Image(systemName: "photo")
                .largeTitle()
                .secondary()
            
            if let url {
                AsyncImage(url: url, transaction: Transaction(animation: .default)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                        
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                        
                    case .failure:
                        Image(systemName: "exclamationmark.triangle")
                            .largeTitle()
                            .secondary()
                        
                    @unknown default:
                        Image(systemName: "photo")
                            .largeTitle()
                            .secondary()
                    }
                }
            }
        }
        .aspectRatio(16 / 9, contentMode: .fit)
        .clipShape(.rect(cornerRadius: 8))
        .accessibilityHidden(true)
    }
}
