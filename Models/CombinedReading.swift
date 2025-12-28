import Foundation

/// The unified model containing fields from both AQSample and PMSizes
struct CombinedReading: Identifiable, Equatable {
    let id = UUID()
    var dt: Date
    
    // AQSample Fields (default to 0 or nil)
    var aqId: Int = 0
    var tVOC: Int = 0
    var eCO2: Int = 0
    var humidity: Double = 0
    var temperature: Double = 0
    
    // PMSizes Fields (default to 0)
    var pmId: Int = 0
    var pm03um: Int = 0
    var pm100s: Int = 0
   
   var timeString: String {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "HH:mm:ss"
      return dateFormatter.string(from: dt)
   }
   
   var unBiasedECO2AndScaled: Double {
      let x = Double((eCO2-400))*0.1
      return Double(round(1000 * x) / 1000)
   }

   var scaledTVOC: Double {
      let x = Double(tVOC)*0.1
      return Double(round(1000 * x) / 1000)
   }
}
