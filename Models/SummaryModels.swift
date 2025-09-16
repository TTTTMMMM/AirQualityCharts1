import Foundation

struct AvgValuesPM {
   var pm03um: Int = 0
   var pm10s: Int = 0
   var pm25s:  Int = 0
   var pm100s: Int = 0
}

struct MaxValuesPM {
   var pm03um: Int = 0
   var pm10s: Int = 0
   var pm25s:  Int = 0
   var pm100s: Int = 0
}

struct AvgValuesAQ {
   var scaledTVOC: Int = 0
   var unbiasedScaledECO2: Int = 0
   var temperature: Int = 0
   var humidity: Int = 0
}

struct MaxValuesAQ {
   var scaledTVOC: Int = 0
   var unbiasedScaledECO2: Int = 0
   var temperature: Double = 0.0
   var humidity: Double = 0.0
}

enum MetricType {
    case temperature
    case humidity
    case count
}

