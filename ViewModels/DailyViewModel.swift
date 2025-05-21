//
// https://www.youtube.com/playlist?list=PLwvDm4Vfkdphl8ly0oi0aHx0v2B7UvDK0
//
import Foundation
import FirebaseFirestore

class DailyViewModel: ObservableObject {
   
   @Published var aqMeasurements: [AQSample] = []
   @Published private(set) var aqSample: AQSample? = nil
   private var whichDataSet: Int = 1
   private var todayTimestamp: Int = Int(Date().timeIntervalSince1970)
   
   init() {
      print("AQViewModel.init()")
   }
   
   func createSample() async throws {
      let firebaseID = "00Acz98Ndoq0x5tr2uWO"
      let aqSample = AQSample(id: 3698, tVOC: 3, dt: Date(), eCO2: 401, forwarder: "forwarder_NAS-220P", humidity: 34.1, temperature: 71.4)
      
      try? await AirQualityDataManager.shared.createSample(firebaseID: firebaseID, aqSample: aqSample)
   }
   
   func getSample() async throws {
      let firebaseID = "0046sa5vLc00OjjKPIGD"
      //      let firebaseID = "00Acz98Ndoq0x5tr2uWO"
      self.aqSample = try await AirQualityDataManager.shared.getAQSample(firebaseID: firebaseID)
      print("\(firebaseID) -> \(self.aqSample.debugDescription)")
      let ds = self.aqSample?.dateString ?? "nil"
      let ts = self.aqSample?.timeString ?? "nil"
      print("\(ds)")
      print("\(ts)")
   }
   
   func getAQMeasurements(dt: Int) async throws -> () {  // returns Void
      print("getAQMeasurements(\(dt))")
      try? await Task.sleep(for: .seconds(3))
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
