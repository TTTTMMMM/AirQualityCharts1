//
// https://www.youtube.com/playlist?list=PLwvDm4Vfkdphl8ly0oi0aHx0v2B7UvDK0
//  Specifically, Fetching Firebase Firestore data with Codable in Swift | Firebase Bootcamp #10
//
import Foundation

struct PMSizes: Identifiable, Equatable, Codable {
   var id: Int
   var dt: Date
   var pm03um: Int  // # num particles > .3µm
   var pm05um: Int  // # num particles > .5µm
   var pm1um: Int   // # num particles > 1µm
   var pm25um: Int  // # num particles > 2.5µm
   var pm5um: Int   // # num particles > 5µm
   var pm10um: Int  // # num particles > 10µm

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
   
   var scaledPM05um: Int {
      return Int(round(Double(pm05um)*0.1))
   }
   
   var scaledPM1um: Int {
      return Int(round(Double(pm1um)*0.1))
   }
   
   
   // the right hand side of the = is what the key is called
   // in the firestore database
   // e.g., the struct uses tVOC (lowercase t), but Firebase has it
   // defined as TVOC (uppercase T)
   enum CodingKeys: String, CodingKey {
      case id           = "id"
      case dt           = "dt"
      case pm03um       = "pm03um"
      case pm05um       = "pm05um"
      case pm1um        = "pm1um"
      case pm25um       = "pm25um"
      case pm5um        = "pm5um"
      case pm10um       = "pm10um"
   }
   
   // when we download from firebase, we're going to decode the firebase document
   // into whatever sits on the left hand side of the = sign
      mutating func decode(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      self.id = try container.decode(Int.self, forKey: .id)
      self.dt = try container.decode(Date.self, forKey: .dt)
      self.pm03um = try container.decode(Int.self, forKey: .pm03um)
      self.pm05um = try container.decode(Int.self, forKey: .pm05um)
      self.pm1um = try container.decode(Int.self, forKey: .pm1um)
      self.pm25um = try container.decode(Int.self, forKey: .pm25um)
      self.pm5um = try container.decode(Int.self, forKey: .pm5um)
      self.pm10um = try container.decode(Int.self, forKey: .pm10um)
   }
   
   func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(id, forKey: .id)
      try container.encode(dt, forKey: .dt)
      try container.encode(pm03um, forKey: .pm03um)
      try container.encode(pm05um, forKey: .pm05um)
      try container.encode(pm1um, forKey: .pm1um)
      try container.encode(pm25um, forKey: .pm25um)
      try container.encode(pm5um, forKey: .pm5um)
      try container.encode(pm10um, forKey: .pm10um)
   }
}
