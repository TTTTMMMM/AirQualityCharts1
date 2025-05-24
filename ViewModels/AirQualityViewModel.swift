//
// https://www.youtube.com/playlist?list=PLwvDm4Vfkdphl8ly0oi0aHx0v2B7UvDK0
//
import Foundation
import FirebaseFirestore

@MainActor
class AirQualityViewModel: ObservableObject {
   
   @Published var aqMeasurements: [AQSample] = []
   @Published private(set) var aqSample: AQSample? = nil
   @Published var dailyFreebiesLeft: Int? = nil
   
   init() {
   }
   
   enum HoursDuration: String, CaseIterable {
      case one   = "1"
      case two   = "2"
      case three = "3"
      case four  = "4"
      case five  = "5"
      case six   = "6"
      case seven = "7"
      case eight = "8"
   }
   
   // I won't be using this in the app, just here to create a test sample
   func createSample() async throws {
      let firebaseID = "00Acz98Ndoq0x5tr2uWO"
      let aqSample = AQSample(
         id: 3698,
         tVOC: 3,
         dt: Date(),
         eCO2: 401,
         forwarder: "forwarder_NAS-220P",
         humidity: 34.1,
         temperature: 71.4
      )
      
      try? await AirQualityDataManager.shared.createSample(firebaseID: firebaseID, aqSample: aqSample)
   }
   
   // I won't be using this in the app, just here to get a test sample to see how a sample comes back from Firebase
   func getSample() async throws {
      let firebaseID = "0046sa5vLc00OjjKPIGD"
      //      let firebaseID = "00Acz98Ndoq0x5tr2uWO"
      let aqs = try await AirQualityDataManager.shared.getAQSample(firebaseID: firebaseID)
      await MainActor.run {
         self.aqSample = aqs
         print("\(firebaseID) -> \(self.aqSample.debugDescription)")
         let ds = self.aqSample?.dateString ?? "nil"
         let ts = self.aqSample?.timeString ?? "nil"
         print("\(ds)")
         print("\(ts)")
      }
   }
   
   func getOneDayOfSamples(date: Date) async throws {
      let samples = try? await AirQualityDataManager.shared.getSamplesByDate(date: date)
      if let samples = samples {
         try? await self.subtractFreebliesLeft(numSamplesToRemove: samples.count)
//         samples.forEach {
//            print($0.dateString, $0.temperature)
//            print($0.humidity)
//            print($0.unBiasedECO2)
//            print($0.tVOC)
//            print("----")
//         }
         await MainActor.run {
            self.aqMeasurements = samples
         }
      }
   }
   
   func getSecifiedHoursWorthOfSamples(date: Date, numberOfHours: Int) async throws {
      let samples = try? await AirQualityDataManager.shared.getSamplesByHour(date: date, numberOfHours: numberOfHours)
      if let samples = samples {
         try? await self.subtractFreebliesLeft(numSamplesToRemove: samples.count)
//         samples.forEach {
//            print($0.dateString, $0.temperature)
//            print($0.humidity)
//            print($0.unBiasedECO2)
//            print($0.tVOC)
//            print("----")
//         }
         await MainActor.run {
            self.aqMeasurements = samples
         }
      }
   }
   
   func getFreebiesLeft() async throws {
      // Get the current number of free samples left from firestore database
      var freebies = try? await AirQualityDataManager.shared.getNumFreebies()
      if let freebies = freebies {
         // update the UI on the Main thread
         await MainActor.run {
            self.dailyFreebiesLeft = freebies.numLeft
         }
      }
   }
   
   private func subtractFreebliesLeft(numSamplesToRemove: Int) async throws {
      // Get the current number of free samples left from firestore database
      var freebies = try? await AirQualityDataManager.shared.getNumFreebies()
      if var numFreebies = freebies {    // safely unwrap the result
         // subtract the number of free samples left and update the firestore database
         numFreebies.numLeft = numFreebies.numLeft - numSamplesToRemove
         try? await AirQualityDataManager.shared.setNumFreebies(freebies: numFreebies)
      }
      // Read the updated current number of free samples left from firestore database
      freebies = try? await AirQualityDataManager.shared.getNumFreebies()
      if let newNumFreebies = freebies { // safely unwrap the result
         // update the UI on the Main thread
         await MainActor.run {
            self.dailyFreebiesLeft = newNumFreebies.numLeft
         }
      }
   }
   
}
