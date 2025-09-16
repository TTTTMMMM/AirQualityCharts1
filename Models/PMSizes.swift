//
// https://www.youtube.com/playlist?list=PLwvDm4Vfkdphl8ly0oi0aHx0v2B7UvDK0
//  Specifically, Fetching Firebase Firestore data with Codable in Swift | Firebase Bootcamp #10
//
import Foundation

struct PMSizes: Identifiable, Equatable, Codable {
   var id: Int
   var dt: Date
   var pm03um: Int  // # num particles > .3µm
   var pm10s:  Int  // PM1.0 standard concentration µg/m³
   var pm25s:  Int  // PM2.5 standard concentration µg/m³
   var pm100s: Int  // PM10  standard concentration µg/m³

   var dateString: String {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
      return dateFormatter.string(from: dt)
   }
   
   var timeString: String {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "HH:mm:ss"
      return dateFormatter.string(from: dt)
   }

   var scaledPM03um: Int {
      return Int(round(Double(pm03um)*0.1))
   }
   
   // the right hand side of the = is what the key is called
   // in the firestore database
   // e.g., the struct uses tVOC (lowercase t), but Firebase has it
   // defined as TVOC (uppercase T)
   enum CodingKeys: String, CodingKey {
      case id           = "id"
      case dt           = "dt"
      case pm03um       = "pm03um"
      case pm10s        = "pm10s"
      case pm25s        = "pm25s"
      case pm100s       = "pm100s"
   }
   
   // when we download from firebase, we're going to decode the firebase document
   // into whatever sits on the left hand side of the = sign
      mutating func decode(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      self.id = try container.decode(Int.self, forKey: .id)
      self.dt = try container.decode(Date.self, forKey: .dt)
      self.pm03um = try container.decode(Int.self, forKey: .pm03um)
      self.pm10s = try container.decode(Int.self, forKey: .pm10s)
      self.pm25s = try container.decode(Int.self, forKey: .pm25s)
      self.pm100s = try container.decode(Int.self, forKey: .pm100s)
   }
   
   func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(id, forKey: .id)
      try container.encode(dt, forKey: .dt)
      try container.encode(pm03um, forKey: .pm03um)
      try container.encode(pm10s, forKey: .pm10s)
      try container.encode(pm25s, forKey: .pm25s)
      try container.encode(pm100s, forKey: .pm100s)
   }
}
