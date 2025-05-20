import Foundation

struct AQSample: Identifiable, Equatable, Codable {
   let id: Int
   let tVOC: Int
//   let dt: Double
   let dt: Date
   let eCO2: Int
   let forwarder: String?
   let humidity: Double
   let temperature: Double
   var dateString: String {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//      return dateFormatter.string(from: Date(timeIntervalSince1970: dt))
      return dateFormatter.string(from: Date())
   }
   var timeString: String {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "HH:mm"
//      return dateFormatter.string(from: Date(timeIntervalSince1970: dt))
      return dateFormatter.string(from: Date())
   }
   var unBiasedECO2: Int {
      return eCO2-400
   }
}
