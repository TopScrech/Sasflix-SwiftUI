import SwiftUI

struct VideoDownloadProgressView: View {
    let progress: VideoDownloadProgress
    
    var body: some View {
        VStack(alignment: .leading) {
            if let fractionCompleted = progress.fractionCompleted {
                ProgressView(value: fractionCompleted)
            } else {
                ProgressView()
            }
            
            VStack(alignment: .leading) {
                Text(progress.progressText)
                    .caption()
                    .secondary()
                
                Text("\(progress.speedText) \(progress.remainingText)")
                    .caption()
                    .secondary()
            }
        }
    }
}
