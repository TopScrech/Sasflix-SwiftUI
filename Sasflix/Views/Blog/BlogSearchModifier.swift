import SwiftUI

struct BlogSearchModifier: ViewModifier {
    let isVisible: Bool
    @Binding var text: String
    
    func body(content: Content) -> some View {
        if isVisible {
            content.searchable(text: $text, prompt: "Поиск")
        } else {
            content
        }
    }
}

extension View {
    func blogSearch(isVisible: Bool, text: Binding<String>) -> some View {
        modifier(BlogSearchModifier(isVisible: isVisible, text: text))
    }
}
