import SwiftUI

struct LoadingStateView: View {
    private let title: String
    
    init(_ title: String) {
        self.title = title
    }
    
    var body: some View {
        ContentUnavailableView {
            ProgressView()
        } description: {
            Text(title)
        }
    }
}
