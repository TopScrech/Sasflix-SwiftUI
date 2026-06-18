import SwiftUI

struct DebugSettings: View {
    @AppStorage(DebugSettingKey.hideSubscriptionRequiredVideos) private var hideSubscriptionRequiredVideos = true
    
    var body: some View {
        List {
            Section("Лента") {
                Toggle("Скрывать видео по подписке", isOn: $hideSubscriptionRequiredVideos)
            }
            
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
