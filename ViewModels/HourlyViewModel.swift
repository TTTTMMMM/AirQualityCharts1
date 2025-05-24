//
// https://www.youtube.com/playlist?list=PLwvDm4Vfkdphl8ly0oi0aHx0v2B7UvDK0
//
import Foundation
import FirebaseFirestore

@MainActor
class HourlyViewModel: ObservableObject {
   
   @Published var aqMeasurements: [AQSample] = []
   @Published private(set) var aqSample: AQSample? = nil
   @Published var dailyFreebiesLeft: Int? = nil

   init() {
   }
   
   enum HoursDuration: String, CaseIterable {
      case one   = "1"
      case two   = "2"
      case three = "3"
      case four  = "4"
      case five  = "5"
      case six   = "6"
      case seven = "7"
      case eight = "8"
   }
   
   func getOneHourOfSamples(date: Date, numberOfHours: Int) async throws {
      let samples = try? await AirQualityDataManager.shared.getSamplesByHour(date: date, numberOfHours: numberOfHours)
      if let samples = samples {
         try? await self.subtractFreebliesLeft(numSamplesToRemove: samples.count)
//         samples.forEach {
//            print($0.dateString, $0.temperature)
//            print($0.humidity)
//            print($0.unBiasedECO2)
//            print($0.tVOC)
//            print("----")
//         }
         await MainActor.run {
            self.aqMeasurements = samples
         }
      }
   }
   
   func getFreebiesLeft() async throws {
      var numFreebies = try? await AirQualityDataManager.shared.getNumFreebies()
      if let newNumFreebies = numFreebies {
         await MainActor.run {
            self.dailyFreebiesLeft = newNumFreebies.numLeft
         }
      }
   }
   
   private func subtractFreebliesLeft(numSamplesToRemove: Int) async throws {
      var numFreebies = try? await AirQualityDataManager.shared.getNumFreebies()
      if var numFreebies = numFreebies {
         numFreebies.numLeft = numFreebies.numLeft - numSamplesToRemove
         try? await AirQualityDataManager.shared.setNumFreebies(freebies: numFreebies)
      }
      numFreebies = try? await AirQualityDataManager.shared.getNumFreebies()
      if let newNumFreebies = numFreebies {
         await MainActor.run {
            self.dailyFreebiesLeft = newNumFreebies.numLeft
         }
      }
   }
   
}
