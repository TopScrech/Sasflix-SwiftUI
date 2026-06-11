import SwiftUI

struct MetadataBadgeView: View {
    let title: String
    let systemImage: String
    
    var body: some View {
        Label(title, systemImage: systemImage)
            .caption()
            .secondary()
    }
}
