import Foundation

class AQViewModel: ObservableObject {
   
   @Published var aqMeasurements: [AQMeasurement] = []
   private var whichDataSet: Int = 1
   private var todayTimestamp: Int = Int(Date().timeIntervalSince1970)
   
   init() {
      print("AQViewModel.init()")
   }
   
   func getAQMeasurements(dt: Int) async throws -> () {  // returns Void
      print("getAQMeasurements(\(dt))")
      try? await Task.sleep(for: .seconds(3))
      let data: [AQMeasurement]
      if (self.whichDataSet == 1) {
         data = DataLoader.mockDataDay2
         self.whichDataSet = 2
      } else {
         data = DataLoader.mockDataDay1
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
