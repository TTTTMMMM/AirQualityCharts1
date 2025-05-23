//
// https://www.youtube.com/playlist?list=PLwvDm4Vfkdphl8ly0oi0aHx0v2B7UvDK0
//
import Foundation
import FirebaseFirestore

@MainActor
class DailyViewModel: ObservableObject {
   
   @Published var aqMeasurements: [AQSample] = []
   @Published private(set) var aqSample: AQSample? = nil
   
   init() {
      print("DailyViewModel.init()")
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
         print("🐰 \(samples.count) 🐰 \(samples.last?.dateString ?? "n/a") 🐰")
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
   
}
