import ScrechKit

struct AccountNotificationSettingsView: View {
    let user: AuthenticatedUser
    let isUpdating: Bool
    let updateNotificationSettings: (Bool, Bool, Bool) -> Void
    
    @State private var notifyEmail = false
    @State private var notifyWeb = false
    @State private var notifyApp = false
    
    var body: some View {
        Section("Отправлять уведомления") {
            Toggle("на почту", isOn: $notifyEmail)
            Toggle("в колокольчик на сайте", isOn: $notifyWeb)
            Toggle("в приложение", isOn: $notifyApp)
        }
        .disabled(isUpdating)
        .onAppear {
            sync(with: user)
        }
        .onChange(of: user) { _, newUser in
            sync(with: newUser)
        }
        .onChange(of: notifyEmail) {
            updateSettings()
        }
        .onChange(of: notifyWeb) {
            updateSettings()
        }
        .onChange(of: notifyApp) {
            updateSettings()
        }
    }
    
    private func sync(with user: AuthenticatedUser) {
        notifyEmail = user.notifyEmail ?? false
        notifyWeb = user.notifyWeb ?? false
        notifyApp = user.notifyApp ?? false
    }
    
    private func updateSettings() {
        guard !isUpdating,
              notifyEmail != (user.notifyEmail ?? false)
                || notifyWeb != (user.notifyWeb ?? false)
                || notifyApp != (user.notifyApp ?? false) else {
            return
        }
        
        updateNotificationSettings(notifyEmail, notifyWeb, notifyApp)
    }
}
