import Foundation
import FirebaseAuth

struct AuthDataResultModel {
   let uid: String
   let email: String?
   let photoURL: String?
   
   init(user: User) {
      self.uid = user.uid
      self.email = user.email
      self.photoURL = user.photoURL?.absoluteString
   }
}

final class AuthenticationManager {
   static let shared = AuthenticationManager()
   private init() {}
   
   
   func getAuthenticatedUser() throws -> AuthDataResultModel {
      guard let user = Auth.auth().currentUser else {
         throw URLError(.badServerResponse)
      }
      return(AuthDataResultModel(user: user))
   }
   
   func signOut() throws -> () {
      try Auth.auth().signOut()
   }
   
}

// MARK: Sign in with Google
extension AuthenticationManager {
   
   @discardableResult
   func signInWithGoogle(tokens: GoogleSignInResult) async throws -> AuthDataResultModel {
      let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accesToken)
      return try await signIn(credential: credential)
   }
   
   func signIn(credential: AuthCredential) async throws -> AuthDataResultModel {
      let authDataResult = try await Auth.auth().signIn(with: credential)
      return(AuthDataResultModel(user: authDataResult.user))
   }
   
}
