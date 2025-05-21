import Foundation


// To convert the timestamp coming from Firebase to local time

struct AQSample: Identifiable, Equatable, Codable {
   let id: Int
   let TVOC: Int
   let dt: Date
   let eCO2: Int
   let forwarder: String?
   let humidity: Double
   let temperature: Double
   var dateString: String {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
      return dateFormatter.string(from: dt)
   }
   var timeString: String {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "HH:mm"
      return dateFormatter.string(from: dt)
   }
   var unBiasedECO2: Int {
      return eCO2-400
   }
}
