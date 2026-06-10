import SwiftUI

struct TopicPlaybackStatusView: View {
	let posterURL: URL?
	let title: String
	let systemImage: String
	let message: String

	var body: some View {
		ZStack {
			RemotePosterView(url: posterURL)

			Rectangle()
				.fill(.black.opacity(0.35))
				.clipShape(.rect(cornerRadius: 8))

			VStack {
				Image(systemName: systemImage)
					.font(.largeTitle)

				Text(title)
					.font(.headline)
					.bold()

				Text(message)
					.font(.subheadline)
					.multilineTextAlignment(.center)
			}
			.foregroundStyle(.white)
			.padding()
			.background(.regularMaterial, in: .rect(cornerRadius: 8))
			.padding()
		}
		.aspectRatio(16 / 9, contentMode: .fit)
	}
}
