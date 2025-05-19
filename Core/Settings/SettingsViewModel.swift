import Foundation


@MainActor
final class SettingViewModel: ObservableObject {
   
   
   func signOut() throws {
      
      try AuthenticationManager.shared.signOut()
   }
}
