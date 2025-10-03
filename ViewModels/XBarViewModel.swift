import Foundation

@MainActor
final class XBarViewModel: ObservableObject {
   
   @Published var aqDailyXBar: [XBarAQ] = []
   @Published var pmDailyXBar: [XBarPM] = []
   @Published var dailyFreebiesLeft: Int? = nil
   @Published var numberOfDaysRetrieved: Int? = 0

   
   init() {
      Task {
         try? await self.getFreebiesLeft()
      }
   }
   
   func getXBar(startingFrom: Date, endingAt: Date = Date()) async throws {
      print("In getXBar, startingFrom: \(startingFrom), endingAt: \(endingAt)")
      if let daysOfAveragesAQ = try? await DataManager.shared.getXBarAQ(
         startingFrom: startingFrom,
         endingAt: endingAt
      ) {
         try? await self.subtractFreebliesLeft(numSamplesToRemove: daysOfAveragesAQ.count)
            self.numberOfDaysRetrieved = daysOfAveragesAQ.count
         await MainActor.run {
            self.aqDailyXBar = daysOfAveragesAQ
         }
      }
      
      if let daysOfAveragesPM = try? await DataManager.shared.getXBarPM(
         startingFrom: startingFrom,
         endingAt: endingAt
      ) {
         try? await self.subtractFreebliesLeft(numSamplesToRemove: daysOfAveragesPM.count)
            self.numberOfDaysRetrieved = daysOfAveragesPM.count
         await MainActor.run {
            self.pmDailyXBar = daysOfAveragesPM
         }
      }
   }
   
   func getFreebiesLeft() async throws {
      // Get the current number of free samples left from firestore database
      if let freebies = try? await DataManager.shared.getNumFreebies() {
         // after safely unwrapping, update the UI on the Main thread
         await MainActor.run {
            self.dailyFreebiesLeft = freebies.numLeft
         }
      }
   }
   
   private func subtractFreebliesLeft(numSamplesToRemove: Int) async throws {
      // Get the current number of free samples left from firestore database
      if var numFreebies = try? await DataManager.shared.getNumFreebies() {
         // after safely unwrapping the result
         // subtract the number of free samples left and update the firestore database
         numFreebies.numLeft = numFreebies.numLeft - numSamplesToRemove
         try? await DataManager.shared.setNumFreebies(freebies: numFreebies)
         await MainActor.run {
            self.dailyFreebiesLeft = numFreebies.numLeft
         }
      }
   }
   
   
}
