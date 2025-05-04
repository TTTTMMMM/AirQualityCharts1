import Foundation

class AQViewModel: ObservableObject {
   
   @Published var aqMeasurements: [AQMeasurement] = []
   @Published var startingIndex: Int?
   
   init() {
      print("init() of AQViewModel called...")
      let aqMeasurements = AQDataService.measurements
      self.aqMeasurements = aqMeasurements
      if let sI = aqMeasurements.firstIndex(where: { $0.id == 23904}) {
         self.startingIndex = sI  // should be 0
      } else {
         self.startingIndex = nil
      }
   }
   
   func getAQMeasurements(dt: Int) -> Void {
      print("Entering getAQMeasurements(), number of elements in aqMeasurements is \(aqMeasurements.count)")
      self.aqMeasurements.removeFirst()
      print("Exiting getAQMeasurements(), number of elements in aqMeasurements is \(aqMeasurements.count)")
   }
      
   
}
