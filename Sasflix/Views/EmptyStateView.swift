import SwiftUI

struct EmptyStateView: View {
    let title: String
    let systemImage: String
    let message: String
    
    var body: some View {
        ContentUnavailableView(title, systemImage: systemImage, description: Text(message))
    }
}
