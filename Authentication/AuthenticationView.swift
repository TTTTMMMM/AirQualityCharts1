import SwiftUI
import GoogleSignIn        // used to create Google Signin Button in the view
import GoogleSignInSwift   // used to create Google Signin Button in the view

@MainActor
final class AuthenticationViewModel: ObservableObject {
   
   func signInGoogle() async throws {
      let helper = SignInGoogleHelper()
      let tokens = try await helper.signIn()
      try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
   }
}

struct AuthenticationView: View {
   
   @StateObject private var viewModel = AuthenticationViewModel()
   @Binding var showSignInView: Bool
   
    var body: some View {
       VStack {
          GoogleSignInButton(
            viewModel:GoogleSignInButtonViewModel(
                  scheme: .dark,
                  style: .wide,
                  state: .normal
               )
          ) {
             Task {
                do {
                   try await viewModel.signInGoogle()
                   showSignInView = false
                } catch {
                   print(error)
                }
             }
          }
          .font(.headline)
          .cornerRadius(10)
          .shadow(radius: 20)
          
          Spacer()
       }
       .padding()
       .navigationTitle("Sign In")
    }
}

#Preview {
   NavigationStack {
      AuthenticationView(showSignInView: .constant(false))
   }
}
