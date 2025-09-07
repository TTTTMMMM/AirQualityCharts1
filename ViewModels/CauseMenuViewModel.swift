import Foundation

@MainActor
final class CauseMenuViewModel: ObservableObject {
   
   @Published var selectedCause: Cause? = nil
   
   enum Cause: String, CaseIterable {
      case woodStove = "Wood Stove"
      case cleaners  = "Cleaners"
      case pollen    = "Pollen"
      case cooking   = "Cooking"
      case breath    = "Breath"
      case other     = "Other"
      case unknown   = "Unknown"
      case remove    = "Remove Cause"
   }
   
   func updateCause(reason: Cause) async -> () {
      // get the desired aqSample, get the firebaseID and update the reason
      let firebaseID = "00Acz98Ndoq0x5tr2uWO"
      switch reason {
         case .remove:
            self.selectedCause = nil
            try? await DataManager.shared.updateCause(firebaseID: firebaseID, reason: nil)
            break
         default :
            self.selectedCause = reason
            try? await DataManager.shared.updateCause(firebaseID: firebaseID, reason: reason.rawValue)
            break
      }
      
   }
}
