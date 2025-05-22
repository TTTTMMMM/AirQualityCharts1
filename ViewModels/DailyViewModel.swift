//
// https://www.youtube.com/playlist?list=PLwvDm4Vfkdphl8ly0oi0aHx0v2B7UvDK0
//
import Foundation
import FirebaseFirestore

@MainActor
class DailyViewModel: ObservableObject {
   
   @Published var aqMeasurements: [AQSample] = []
   @Published private(set) var aqSample: AQSample? = nil
   private var whichDataSet: Int = 1
   
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
   
   func updateCause(reason: String) async -> () {
      // still don't know if I'll pass in a firbaseID or an AQSample from which to get the firebaseID
      let firebaseID = "00Acz98Ndoq0x5tr2uWO"
      var aqs: AQSample? = nil
      Task {
         try await AirQualityDataManager.shared.setCause(firebaseID: firebaseID, reason: reason)
         aqs = try await AirQualityDataManager.shared.getAQSample(firebaseID: firebaseID)   //get the updated value to verify the update worked
         await MainActor.run {
            if let aqs {
               self.aqSample = aqs
            }
            print("In updateCause() \n \(firebaseID) -> \(self.aqSample.debugDescription)")
         }
      }
   }
   
   func getAQMeasurements(dt: Int) async throws -> () {  // returns Void
      print("getAQMeasurements(\(dt))")
      try? await Task.sleep(for: .seconds(1))
      let data: [AQSample]
      if (self.whichDataSet == 1) {
         data = AirQualityDataManager.mockDataDay2
         self.whichDataSet = 2
      } else {
         data = AirQualityDataManager.mockDataDay1
         self.whichDataSet = 1
      }
      await MainActor.run {
         self.aqMeasurements = data
      }
   }
   
   func clearAQMeasurements() async throws -> () {  // returns Void
      print("clearAQMeasurements()")
      try? await Task.sleep(for: .seconds(1))
      await MainActor.run {
         self.aqMeasurements = []
      }
   }
   
   
}
