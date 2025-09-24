import Foundation

struct AveragesAQ: Codable {
   var count: Int
   var tVOC: Int
   var eCO2: Int
   var temperature: Int
   var humidity: Int
   var dt: Date
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
      case tVOC         = "TVOC"
      case dt           = "dt"
      case eCO2         = "eCO2"
      case humidity     = "humidity"
      case temperature  = "temperature"
      case ttl          = "ttl"
   }

   // when we download from firebase, we're going to decode the firebase document
   // into whatever sits on the left hand side of the = sign
      mutating func decode(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      self.count = try container.decode(Int.self, forKey: .count)
      self.tVOC = try container.decode(Int.self, forKey: .tVOC)
      self.dt = try container.decode(Date.self, forKey: .dt)
      self.eCO2 = try container.decode(Int.self, forKey: .eCO2)
      self.humidity = try container.decode(Int.self, forKey: .humidity)
      self.temperature = try container.decode(Int.self, forKey: .temperature)
      self.ttl = try container.decode(Date.self, forKey: .ttl)
   }
   
   func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(count, forKey: .count)
      try container.encode(tVOC, forKey: .tVOC)
      try container.encode(dt, forKey: .dt)
      try container.encode(eCO2, forKey: .eCO2)
      try container.encode(humidity, forKey: .humidity)
      try container.encode(temperature, forKey: .temperature)
      try container.encode(ttl, forKey: .ttl)
   }
}
