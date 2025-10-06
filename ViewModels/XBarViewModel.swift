import Foundation

@MainActor
final class XBarViewModel: ObservableObject {
   
   private var aqDailyXBar: [XBarAQ] = []
   private var pmDailyXBar: [XBarPM] = []
   private var comboDailies: [combinedXBar] = []
   @Published var combinedDailyXBar: [combinedXBar] = []
   @Published var dailyFreebiesLeft: Int? = nil
   @Published var numberOfDaysRetrieved: Int? = 0

   
   init() {
      Task {
         try? await self.getFreebiesLeft()
      }
   }
   
   func getXBar(startingFrom: Date, endingAt: Date = Date()) async throws {
      if let daysOfAveragesAQ = try? await DataManager.shared.getXBarAQ(
         startingFrom: startingFrom,
         endingAt: endingAt
      ) {
         try? await self.subtractFreebliesLeft(numSamplesToRemove: daysOfAveragesAQ.count)
            self.numberOfDaysRetrieved = daysOfAveragesAQ.count
            self.aqDailyXBar = daysOfAveragesAQ
      }
      
      if let daysOfAveragesPM = try? await DataManager.shared.getXBarPM(
         startingFrom: startingFrom,
         endingAt: endingAt
      ) {
         try? await self.subtractFreebliesLeft(numSamplesToRemove: daysOfAveragesPM.count)
            self.numberOfDaysRetrieved = daysOfAveragesPM.count
            self.pmDailyXBar = daysOfAveragesPM
      }
      
      self.comboDailies = combineDailies(aqDailyXBar: aqDailyXBar, pmDailyXBar: pmDailyXBar)
         await MainActor.run {
            self.combinedDailyXBar = comboDailies
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
   
   private func combineDailies(aqDailyXBar: [XBarAQ], pmDailyXBar: [XBarPM]) -> [combinedXBar] {
       // A dictionary is used for efficient lookup of XBarAQ items by date.
      var aqDict = [String: XBarAQ]()
      for aqItem in aqDailyXBar {
         if let theID = aqItem.firebaseID {
            aqDict[theID] = aqItem
         }
      }
      
      var pmDict = [String: XBarPM]()
      for pmItem in pmDailyXBar {
         if let theID = pmItem.firebaseID {
            pmDict[theID] = pmItem
         }
      }

      var combinedList = [combinedXBar]()

      var count = 0
      for aqItem in aqDict {
         let key = aqItem.key
         if let pmItem = pmDict[key] {
            let combinedXBarItem = combinedXBar(
               id: key,
               dt: aqItem.value.dt,
               tVOC: aqItem.value.tVOC,
               eCO2: aqItem.value.eCO2,
               humidity: aqItem.value.humidity,
               temperature: aqItem.value.temperature,
               pm03um: pmItem.pm03um,
               pm100s: pmItem.pm100s
            )
            count += 1
            combinedList.append(combinedXBarItem)
         } else {
            let combinedXBarItem = combinedXBar(
               id: key,
               dt: aqItem.value.dt,
               tVOC: aqItem.value.tVOC,
               eCO2: aqItem.value.eCO2,
               humidity: aqItem.value.humidity,
               temperature: aqItem.value.temperature,
               pm03um: 0,
               pm100s: 0
            )
            count += 1
            combinedList.append(combinedXBarItem)
         }
      }
      // Now, iterate through the PM items to find any that weren't matched
      for pmItem in pmDict {
          let key = pmItem.key
          if aqDict[key] == nil {
             // No matching AQ item for this date
             let combinedXBarItem = combinedXBar(
                 id: key,
                 dt: pmItem.value.dt,
                 tVOC: 0,
                 eCO2: 0,
                 humidity: 0,
                 temperature: 0,
                 pm03um: pmItem.value.pm03um,
                 pm100s: pmItem.value.pm100s
             )
             count += 1
             combinedList.append(combinedXBarItem)
          }
      }
      let sortedCombinedList = combinedList.sorted(by: { $0.id < $1.id })
      return sortedCombinedList
   }
}

extension Calendar {
    static let current = Calendar.current
}

extension Date {
    /// Returns the date at the start of the day.
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
}
