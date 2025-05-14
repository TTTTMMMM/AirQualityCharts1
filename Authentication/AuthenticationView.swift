import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

struct GoogleSignInResultModel {
   let idToken: String
   let accesToken: String
}

@MainActor
final class AuthenticationViewModel: ObservableObject {
   
   func signInGoogle() async throws {
      guard let topVC = Utilities.shared.topViewController() else {
         throw URLError(.cannotFindHost)
      }
      let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
      
      guard let idToken = gidSignInResult.user.idToken?.tokenString else {
         throw URLError(.badServerResponse)
      }
      let accessToken = gidSignInResult.user.accessToken.tokenString
      
      let tokens = GoogleSignInResultModel(idToken: idToken, accesToken: accessToken)
      let user = try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
      print(user)
   }
}

struct AuthenticationView: View {
   
   @StateObject private var viewModel = AuthenticationViewModel()
   @Binding var showSignInView: Bool
   
    var body: some View {
       VStack {
          NavigationLink {
             SignInView(showSignInView: $showSignInView)
          } label: {
             Text("Sign In With Email")
                .font(.headline)
                .foregroundColor(.white)
                .frame(height: 55)
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(10)
          }
          
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
