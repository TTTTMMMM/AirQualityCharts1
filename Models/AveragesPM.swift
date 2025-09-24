import Foundation

struct AveragesPM: Codable {
   var count: Int
   var dt: Date
   var pm03um: Int
   var pm100s: Int
   var pm10s: Int
   var pm25s: Int
   var ttl: Date
   
   var dateString: String {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd"
      return dateFormatter.string(from: dt)
   }
   
   // the right hand side of the = is what the key is called
   // in the firestore database
   // e.g., the struct uses tVOC (lowercase t), but Firebase has it
   // defined as TVOC (uppercase T)
   enum CodingKeys: String, CodingKey {
      case count        = "count"
      case dt           = "dt"
      case pm03um       = "pm03um"
      case pm100s       = "pm100s"
      case pm10s        = "pm10s"
      case pm25s        = "pm25s"
      case ttl          = "ttl"
   }

   // when we download from firebase, we're going to decode the firebase document
   // into whatever sits on the left hand side of the = sign
      mutating func decode(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      self.count = try container.decode(Int.self, forKey: .count)
      self.dt = try container.decode(Date.self, forKey: .dt)
      self.pm03um = try container.decode(Int.self, forKey: .pm03um)
      self.pm100s = try container.decode(Int.self, forKey: .pm100s)
      self.pm10s = try container.decode(Int.self, forKey: .pm10s)
      self.pm25s = try container.decode(Int.self, forKey: .pm25s)
      self.ttl = try container.decode(Date.self, forKey: .ttl)
   }
   
   func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(count, forKey: .count)
      try container.encode(dt, forKey: .dt)
      try container.encode(pm03um, forKey: .pm03um)
      try container.encode(pm100s, forKey: .pm100s)
      try container.encode(pm10s, forKey: .pm10s)
      try container.encode(pm25s, forKey: .pm25s)
      try container.encode(ttl, forKey: .ttl)
   }
}

