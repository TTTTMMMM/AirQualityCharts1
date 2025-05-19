import Foundation
import GoogleSignIn
import GoogleSignInSwift

struct GoogleSignInResult {
   let idToken: String
   let accesToken: String
   let name: String?
   let email: String?
   let photoURL: String?
}

final class SignInGoogleHelper {
   
   @MainActor
   func signIn(viewController: UIViewController? = nil) async throws -> GoogleSignInResult {
      guard let topViewController = topViewController() else {
         throw URLError(.notConnectedToInternet)
      }
      // The next line is where the Google Sign-in modal is created in our app and we just sit here until
      // the signin to Google occurs, at which point we get the google tokens and user profile.
      let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topViewController)
      
      guard let idToken = gidSignInResult.user.idToken?.tokenString else {
         throw URLError(.badServerResponse)
      }
      
      let accessToken = gidSignInResult.user.accessToken.tokenString
      let name = gidSignInResult.user.profile?.name
      let email = gidSignInResult.user.profile?.email
      let photoURL = gidSignInResult.user.profile?.imageURL(withDimension: 32)?.absoluteString

      return GoogleSignInResult(idToken: idToken, accesToken: accessToken, name: name, email: email, photoURL: photoURL)
   }

@MainActor
func topViewController(controller: UIViewController? = nil) -> UIViewController? {
   let controller = controller ?? UIApplication.shared.keyWindow?.rootViewController
   if let navigationController = controller as? UINavigationController {
      return topViewController(controller: navigationController.visibleViewController)
   }
   if let tabController = controller as? UITabBarController {
      if let selected = tabController.selectedViewController {
         return topViewController(controller: selected)
      }
   }
   if let presented = controller?.presentedViewController {
      return topViewController(controller: presented)
   }
   return controller
}
}
