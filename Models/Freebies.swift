import Foundation

struct Freebies: Codable {
   var numLeft: Int
   
   enum CodingKeys: String, CodingKey {
      case numLeft = "number_samples_left"
   }
   
   mutating func decode(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      self.numLeft = try container.decode(Int.self, forKey: .numLeft)
   }
   
   func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(numLeft, forKey: .numLeft)
   }
}
