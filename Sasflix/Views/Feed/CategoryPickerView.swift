import SwiftUI

struct CategoryPickerView: View {
    @Binding var selectedCategory: FeedCategory
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(FeedCategory.allCategories) { category in
                    if let systemImage = category.systemImage {
                        Button(category.title, systemImage: systemImage) {
                            selectedCategory = selectedCategory == category ? .all : category
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                        .tint(selectedCategory == category ? .red : .gray)
                    } else {
                        Button(category.title) {
                            selectedCategory = selectedCategory == category ? .all : category
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                        .tint(selectedCategory == category ? .red : .gray)
                    }
                }
            }
            .padding(.bottom)
        }
        .scrollIndicators(.hidden)
    }
}
