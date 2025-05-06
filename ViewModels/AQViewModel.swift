import Foundation

class AQViewModel: ObservableObject {
   
   @Published var aqMeasurements: [AQMeasurement] = []
   @Published var startingIndex: Int?
   
   init() {
      print("AQViewModel.init()")
      let aqMeasurements = AQDataService.measurements
      self.aqMeasurements = aqMeasurements
   }
   
   func getAQMeasurements(dt: Int) -> Void {
      print("AQViewModel.getAQMeasurements()")
      self.aqMeasurements.removeFirst()
   }
      
   
}
