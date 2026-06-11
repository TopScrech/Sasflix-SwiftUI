import SwiftUI

struct DownloadedVideosView: View {
    @Environment(VideoDownloadStore.self) private var downloadStore
    @State private var isConfirmingDeleteAll = false
    
    var body: some View {
        Group {
            if downloadStore.sortedDownloads.isEmpty {
                ContentUnavailableView {
                    Label("Нет загрузок", systemImage: "arrow.down.circle")
                } description: {
                    Text("Скачанные видео появятся здесь")
                }
            } else {
                DownloadedVideosGridView(downloads: downloadStore.sortedDownloads)
            }
        }
        .navigationTitle("Загрузки")
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button("Удалить все", systemImage: "trash", action: showDeleteAllConfirmation)
                    .disabled(downloadStore.sortedDownloads.isEmpty)
            }
        }
        .confirmationDialog("Удалить все загрузки?", isPresented: $isConfirmingDeleteAll) {
            Button("Удалить все", role: .destructive, action: deleteAllDownloads)
            Button("Отмена", role: .cancel) {}
        }
    }
    
    private func showDeleteAllConfirmation() {
        isConfirmingDeleteAll = true
    }
    
    private func deleteAllDownloads() {
        downloadStore.deleteAllDownloads()
    }
}
