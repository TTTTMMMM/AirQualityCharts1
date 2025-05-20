import SwiftUI

@MainActor
final class ProfileViewModel: ObservableObject {
   
   @Published private(set) var user: AuthDataResultModel? = nil
   
   func loadCurrentUser() throws {
      self.user = try AuthenticationManager.shared.getAuthenticatedUser()
   }
}

struct ProfileView: View {
   
   @StateObject private var viewModel = ProfileViewModel()
   @Binding var showSignInView: Bool
   
   var body: some View {
      List {
         if let user = viewModel.user {
            HStack {
               if let email = user.email {
                  Text(email)
               }
               Text("\(user.uid)")
            }
         }
      }
      .onAppear() {
         try? viewModel.loadCurrentUser()
      }
      .navigationTitle("Profile")
      .toolbar {
         ToolbarItem(placement: .navigationBarTrailing) {
            NavigationLink {
               SettingsView(showSignInView: $showSignInView)
            } label: {
               if let user = viewModel.user {
                  if let photoURL = user.photoURL {
                     AsyncImage(url: URL(string: photoURL)){ image in
                        image.resizable()
                     } placeholder: {
                        Color.accentColor
                     }
                     .frame(width: 30, height: 30)
                     .clipShape(.rect(cornerRadius: 25))
                  }
               } else {
                  Image(systemName: "gear")
                     .font(.headline  )
               }
            }
         }
      }
   }
}

#Preview {
   NavigationStack {
      ProfileView(showSignInView: .constant(false))
   }
}
