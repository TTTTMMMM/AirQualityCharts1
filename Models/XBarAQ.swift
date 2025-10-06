//
// https://www.youtube.com/playlist?list=PLwvDm4Vfkdphl8ly0oi0aHx0v2B7UvDK0
//  Specifically, Fetching Firebase Firestore data with Codable in Swift | Firebase Bootcamp #10
//
import Foundation
import FirebaseFirestore

struct XBarAQ: Identifiable, Equatable, Codable {
   @DocumentID var firebaseID: String? // maps the FirebaseID to the
   var id:          String
   var dt:          Date         // date for which averages were computed
   var ttl:         Date         // expiration date of data
   var tVOC:        Int
   var eCO2:        Int
   var humidity:    Int
   var temperature: Int
   var count:       Int         // # of samples used to compute today's average

   var dateString1: String {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
      return dateFormatter.string(from: dt)
   }
   
   var dateString2: String {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd"
      return dateFormatter.string(from: dt)
   }
   
   // the right hand side of the = is what the key is called
   // in the firestore database
   // e.g., the struct uses tVOC (lowercase t), but Firebase has it
   // defined as TVOC (uppercase T)
   enum CodingKeys: String, CodingKey {
      case firebaseID   = "firebaseID"
      case id           = "id"
      case dt           = "dt"
      case ttl          = "ttl"
      case tVOC         = "TVOC"
      case eCO2         = "eCO2"
      case humidity     = "humidity"
      case temperature  = "temperature"
      case count        = "count"
   }
   
   // when we download from firebase, we're going to decode the firebase document
   // into whatever sits on the left hand side of the = sign
      mutating func decode(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      self.firebaseID = try container.decode(String.self, forKey: .firebaseID)
      self.id = try container.decode(String.self, forKey: .id)
      self.dt = try container.decode(Date.self, forKey: .dt)
      self.ttl = try container.decode(Date.self, forKey: .ttl)
      self.tVOC = try container.decode(Int.self, forKey: .tVOC)
      self.eCO2 = try container.decode(Int.self, forKey: .eCO2)
      self.humidity = try container.decode(Int.self, forKey: .humidity)
      self.temperature = try container.decode(Int.self, forKey: .temperature)
      self.count = try container.decode(Int.self, forKey: .count)
   }
   
   func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(firebaseID, forKey: .firebaseID)
      try container.encode(id, forKey: .id)
      try container.encode(dt, forKey: .dt)
      try container.encode(ttl, forKey: .ttl)
      try container.encode(tVOC, forKey: .tVOC)
      try container.encode(eCO2, forKey: .eCO2)
      try container.encode(humidity, forKey: .humidity)
      try container.encode(temperature, forKey: .temperature)
      try container.encode(count, forKey: .count)
   }
}
