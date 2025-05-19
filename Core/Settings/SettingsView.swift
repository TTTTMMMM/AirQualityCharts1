import SwiftUI

struct SettingsView: View {
   
   @StateObject private var viewModel = SettingViewModel()
   @Binding var showSignInView: Bool
   
    var body: some View {
       List {
          Button("Log out") {
             Task {
                do {
                   try viewModel.signOut()
                   showSignInView = true
                } catch {
                   print(error)
                }
             }
          }
       }
       .navigationBarTitle("Settings")
    }
}

#Preview {
   NavigationStack {
      SettingsView(showSignInView: .constant(false))
   }
}
