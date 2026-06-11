import SwiftUI

struct TopUserRowView: View {
    let user: TopUser
    let rank: Int
    
    var body: some View {
        HStack {
            Text(rank, format: .number)
                .monospacedDigit()
                .secondary()
            
            TopUserAvatar(url: user.avatar?.imageURL)
            
            VStack(alignment: .leading) {
                Text(user.displayName)
                    .title()
                
                if let role = user.role, !role.title.isEmpty, role.title != "User" {
                    Text(role.title)
                        .secondary()
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(user.rating, format: .number)
                    .monospacedDigit()
                    .bold()
                
                Text("рейтинг")
                    .secondary()
            }
        }
    }
}
