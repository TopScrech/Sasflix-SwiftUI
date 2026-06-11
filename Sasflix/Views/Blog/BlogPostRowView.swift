import SwiftUI

struct BlogPostRowView: View {
    let post: BlogPost
    
    var body: some View {
        VStack(alignment: .leading) {
            if let imageURL = post.imageURL {
                BlogPostImageView(url: imageURL)
            }
            
            Label("Блог", systemImage: "text.page")
                .caption()
                .secondary()
            
            Text(post.title)
                .headline()
                .lineLimit(2)
            
            Text(post.preview)
                .subheadline()
                .secondary()
                .lineLimit(3)
            
            HStack {
                if let publishedAt = post.publishedAt {
                    Text(publishedAt, format: .dateTime.day().month(.abbreviated).year())
                }
                
                Spacer()
                
                Label("\(post.commentsCount)", systemImage: "bubble")
            }
            .caption()
            .secondary()
        }
        .padding()
        .background(.thinMaterial, in: .rect(cornerRadius: 8))
    }
}
