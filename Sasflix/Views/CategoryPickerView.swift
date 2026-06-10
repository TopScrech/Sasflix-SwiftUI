import SwiftUI

struct CategoryPickerView: View {
	@Binding var selectedCategory: FeedCategory

	var body: some View {
		ScrollView(.horizontal) {
			HStack {
				ForEach(FeedCategory.allCases) { category in
					Button(category.title, systemImage: category.systemImage) {
						selectedCategory = selectedCategory == category ? .all : category
					}
					.buttonStyle(.bordered)
					.controlSize(.small)
					.tint(selectedCategory == category ? .red : .gray)
				}
			}
			.padding(.vertical)
		}
		.scrollIndicators(.hidden)
	}
}
