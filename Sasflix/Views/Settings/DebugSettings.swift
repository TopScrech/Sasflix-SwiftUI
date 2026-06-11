import SwiftUI

struct DebugSettings: View {
    var body: some View {
        List {
            Section("О приложении") {
                LabeledContent("Источник", value: "sasflix.ru/rss.xml")
                
                if let version = Bundle.version {
                    LabeledContent("Версия", value: "v\(version)")
                }
            }
        }
    }
}

#Preview {
    DebugSettings()
}
