import SwiftUI

struct BlogPostView: View {
    @Environment(\.openURL) private var openURL
    
    let post: BlogPost
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                if let imageURL = post.imageURL {
                    BlogPostImageView(url: imageURL)
                }
                
                Text(post.title)
                    .title(.bold)
                
                if let publishedAt = post.publishedAt {
                    Text(publishedAt, format: .dateTime.day().month(.wide).year().hour().minute())
                        .subheadline()
                        .secondary()
                }
                
                Text(post.preview)
                    .font(.body)
                
                Button("Открыть на сайте", systemImage: "safari", action: openOfficialPage)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if let link = post.link {
                ShareLink(item: link)
            }
        }
    }
    
    private func openOfficialPage() {
        guard let link = post.link else {
            return
        }
        
        openURL(link)
    }
}
