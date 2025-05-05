import Foundation
import Charts

struct AQMeasurement: Identifiable, Equatable {
   let id: Int
   let tVOC: Int
   let dt: Double
   let eCO2: Int
   let forwarder: String?
   let humidity: Double
   let temperature: Double
}
