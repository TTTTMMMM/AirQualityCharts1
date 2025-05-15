import Foundation
import GoogleSignIn
import GoogleSignInSwift

struct GoogleSignInResult {
   let idToken: String
   let accesToken: String
}

final class SignInGoogleHelper {
   
   @MainActor
   func signIn(viewController: UIViewController? = nil) async throws -> GoogleSignInResult {
      guard let topViewController = topViewController() else {
         throw URLError(.notConnectedToInternet)
      }
      let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topViewController)
      
      guard let idToken = gidSignInResult.user.idToken?.tokenString else {
         throw URLError(.badServerResponse)
      }
      
      let accessToken = gidSignInResult.user.accessToken.tokenString
      
      return GoogleSignInResult(idToken: idToken, accesToken: accessToken)
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
