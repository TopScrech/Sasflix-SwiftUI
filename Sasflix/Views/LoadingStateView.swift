import SwiftUI

struct LoadingStateView: View {
	let title: String

	var body: some View {
		ContentUnavailableView {
			ProgressView()
		} description: {
			Text(title)
		}
	}
}
