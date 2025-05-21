//
// https://www.youtube.com/playlist?list=PLwvDm4Vfkdphl8ly0oi0aHx0v2B7UvDK0
//  Specifically, Fetching Firebase Firestore data with Codable in Swift | Firebase Bootcamp #10
//
import Foundation

struct AQSample: Identifiable, Equatable, Codable {
   var id: Int
   var tVOC: Int
   var dt: Date
   var eCO2: Int
   var forwarder: String?
   var humidity: Double
   var temperature: Double
   
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
   
   // the right hand side of the = is what the key is called in the firestore database
   // e.g., the struct uses tVOC (lowercase t), but Firebase has it defined as TVOC (uppercase T)
   enum CodingKeys: String, CodingKey {
      case id           = "id"
      case tVOC         = "TVOC"
      case dt           = "dt"
      case eCO2         = "eCO2"
      case forwarder    = "forwarder"
      case humidity     = "humidity"
      case temperature  = "temperature"
   }
   
   // when we download from firebase, we're going to decode the firebase document into whatever sits on the left hand side of the = sign
      mutating func decode(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      self.id = try container.decode(Int.self, forKey: .id)
      self.tVOC = try container.decode(Int.self, forKey: .tVOC)
      self.dt = try container.decode(Date.self, forKey: .dt)
      self.eCO2 = try container.decode(Int.self, forKey: .eCO2)
      self.forwarder = try container.decodeIfPresent(String.self, forKey: .forwarder)
      self.humidity = try container.decode(Double.self, forKey: .humidity)
      self.temperature = try container.decode(Double.self, forKey: .temperature)
   }
   
   func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(id, forKey: .id)
      try container.encode(tVOC, forKey: .tVOC)
      try container.encode(dt, forKey: .dt)
      try container.encode(eCO2, forKey: .eCO2)
      try container.encode(forwarder, forKey: .forwarder)
      try container.encode(humidity, forKey: .humidity)
      try container.encode(temperature, forKey: .temperature)
   }
}
