import SwiftUI

struct AccountProfileTextField: View {
    let field: AccountProfileField?
    @Binding var text: String
    
    var body: some View {
        switch field {
        case .username:
            TextField("Логин", text: $text)
                .textContentType(.username)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            
        case .fullname:
            TextField("Псевдоним", text: $text)
                .textContentType(.nickname)
            
        case .email:
            TextField("E-mail для уведомлений", text: $text)
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .keyboardType(.emailAddress)
            
        case nil:
            EmptyView()
        }
    }
}
