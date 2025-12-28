//
// https://www.youtube.com/playlist?list=PLwvDm4Vfkdphl8ly0oi0aHx0v2B7UvDK0
//
import Foundation
import FirebaseFirestore
import Combine
import CryptoKit

@MainActor
class AirQualityViewModel: ObservableObject {
   
   @Published var aqMeasurements: [AQSample] = []
   @Published private(set) var aqSample: AQSample? = nil
   @Published var dailyFreebiesLeft: Int? = nil
   private  var cancellables = Set<AnyCancellable>()
   private var prevCountOfAQSamples: Int = 0
   @Published var lastSample: AQSample? = nil
   @Published var numberOfSamplesRetrieved: Int? = 0
   @Published var maxValues = MaxValuesAQ()
   @Published var avgValues = AvgValuesAQ()
   @Published var maxValuesLastHour = MaxValuesAQ()
   @Published var avgValuesLastHour = AvgValuesAQ()
   
   init() {
      Task {
         try? await self.getFreebiesLeft()
      }
   }
   
   enum HoursDuration: String, CaseIterable {
      case one   = "1"
      case two   = "2"
      case three = "3"
      case four  = "4"
      case five  = "5"
   }
   
   // I won't be using this in the app, just here to create a test sample
   func createSample() async throws {
      let firebaseID = "00Acz98Ndoq0x5tr2uWO"
      let aqSample = AQSample(
         id: 3698,
         tVOC: 3,
         dt: Date(),
         eCO2: 401,
         forwarder: "forwarder_NAS-220P",
         humidity: 34.1,
         temperature: 71.4
      )
      
      try? await DataManager.shared.createSample(
         firebaseID: firebaseID,
         aqSample: aqSample
      )
   }
   
   // I won't be using this in the app, just here to get a test sample to see how a
   // sample comes back from Firebase
   func getSample() async throws {
      let firebaseID = "0046sa5vLc00OjjKPIGD"
      //      let firebaseID = "00Acz98Ndoq0x5tr2uWO"
      let aqs = try await DataManager.shared.getAQSample(
         firebaseID: firebaseID
      )
      await MainActor.run {
         self.aqSample = aqs
         print("\(firebaseID) -> \(self.aqSample.debugDescription)")
         let ds = self.aqSample?.dateString ?? "nil"
         let ts = self.aqSample?.timeString ?? "nil"
         print("\(ds)")
         print("\(ts)")
      }
   }
   
   func getOneDayOfSamples(date: Date) async throws {
      if let samples = try? await DataManager.shared.getSamplesByDate(
         date: date
      ) {
         try? await self.subtractFreebliesLeft(numSamplesToRemove: samples.count)
            self.numberOfSamplesRetrieved = samples.count
            self.maxValues = computeMaxValues(samples: samples)
            self.avgValues = await computeAvgValues(samples: samples, date: date, store_in_firebase: false)
         await MainActor.run {
            self.aqMeasurements = samples
         }
      }
   }
   
   func getSecifiedHoursWorthOfSamples(date: Date, numberOfHours: Int) async throws {
      if let samples = try? await DataManager.shared.getSamplesByHour(
         date: date,
         numberOfHours: numberOfHours
      ) {
         try? await self.subtractFreebliesLeft(numSamplesToRemove: samples.count)
            self.numberOfSamplesRetrieved = samples.count
            self.maxValues = computeMaxValues(samples: samples)
            self.avgValues = await computeAvgValues(samples: samples, date: date, store_in_firebase: false)
         await MainActor.run {
            self.aqMeasurements = samples
         }
      }
   }
   
   func getFreebiesLeft() async throws {
      // Get the current number of free samples left from firestore database
      if let freebies = try? await DataManager.shared.getNumFreebies() {
         // after safely unwrapping, update the UI on the Main thread
         await MainActor.run {
            self.dailyFreebiesLeft = freebies.numLeft
         }
      }
   }
   
   private func subtractFreebliesLeft(numSamplesToRemove: Int) async throws {
      // Get the current number of free samples left from firestore database
      if var numFreebies = try? await DataManager.shared.getNumFreebies() {
         // after safely unwrapping the result
         // subtract the number of free samples left and update the firestore database
         numFreebies.numLeft = numFreebies.numLeft - numSamplesToRemove
         try? await DataManager.shared.setNumFreebies(freebies: numFreebies)
         await MainActor.run {
            self.dailyFreebiesLeft = numFreebies.numLeft
         }
      }
   }
   
   func addListenerForAQSamples()  {
      DataManager.shared.addListenerForAirQualitySamples()
         .sink { completion in
         } receiveValue: { [weak self] aqsArray in
            self?.aqMeasurements = aqsArray
            Task {
               await MainActor.run {
                  if let lastOne = self?.aqMeasurements.last {
                     self?.lastSample = lastOne
                  }
               }
               for (index, sample) in aqsArray.enumerated() {
                  if(index <= 10) {
                     print("\(sample)")
                  }
               }
               // let's adjust the numFreebies left (+1 in the realCount
               // refers to the read of numFreebies from Firestore to
               // get the current count and then the read to verify after I subtract)
               if let count = self?.aqMeasurements.count {
                  if let prevCount = self?.prevCountOfAQSamples {
                     let realCount = count - prevCount
                     try? await self?.subtractFreebliesLeft(numSamplesToRemove: realCount + 1)
                     self?.prevCountOfAQSamples = prevCount + realCount
                  }
               }
               self?.avgValuesLastHour = self?.computeLastHoursAverages() ?? AvgValuesAQ(scaledTVOC: 0, unbiasedScaledECO2: 0, temperature: 0, humidity: 0)
               self?.maxValuesLastHour = self?.computeLastHoursMaximums() ?? MaxValuesAQ(scaledTVOC: 0, unbiasedScaledECO2: 0, temperature: 0.0, humidity: 0.0)
            }
         }
         // don't forget to store in cancellables, so we can remove listener when we're done
         .store(in: &cancellables)
   }
   
   func cancelCombineSubscriptions()  {
      cancellables.removeAll()
      }
   
   func computeMaxValues(samples: [AQSample]) -> MaxValuesAQ {
      return MaxValuesAQ(
         scaledTVOC: samples.map { Int($0.scaledTVOC)}.max() ?? 0,
         unbiasedScaledECO2: samples.map { Int($0.unBiasedECO2AndScaled)}.max() ?? 0,
         temperature: samples.map { $0.temperature }.max() ?? 0.0,
         humidity: samples.map { $0.humidity }.max() ?? 0.0
      )
   }
   
   func computeAvgValues(samples: [AQSample], date: Date, store_in_firebase: Bool = false) async -> AvgValuesAQ {
      let avgValuesAQ = AvgValuesAQ(
         scaledTVOC: Int(Double(samples.map { $0.scaledTVOC}.reduce(0, +)) / Double(samples.count).rounded()),
         unbiasedScaledECO2: Int(Double(samples.map { $0.unBiasedECO2AndScaled}.reduce(0, +)) / Double(samples.count).rounded()),
         temperature: Int(samples.map { $0.temperature }.reduce(0.0, +) / Double(samples.count).rounded()),
         humidity: Int(samples.map { $0.humidity }.reduce(0.0, +) / Double(samples.count).rounded())
      )
      if(store_in_firebase) {
         let fiveYearsLater = Calendar.current.date(byAdding: .year, value: 5, to: date)
         if let ttl = fiveYearsLater {
            let count = samples.count
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateString = dateFormatter.string(from: date)
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day], from: date)
            guard let startOfDay = calendar.date(from: components) else { return avgValuesAQ }
            let combinedString = "\(dateString)_\(avgValuesAQ.scaledTVOC)-\(avgValuesAQ.unbiasedScaledECO2)-\(avgValuesAQ.temperature)-\(avgValuesAQ.humidity)-\(count)"
            let dataCombinedString = Data(combinedString.utf8)
            let hash = SHA256.hash(data: dataCombinedString)
            let hashString = hash.compactMap { String(format: "%02x", $0) }.joined()
            let index = hashString.index(hashString.startIndex, offsetBy: 11)
            let truncHash = String(hashString.prefix(upTo: index))
            
            let data = XBarAQ(
               id: truncHash,
               dt: startOfDay,
               ttl: ttl,
               tVOC: avgValuesAQ.scaledTVOC,
               eCO2: avgValuesAQ.unbiasedScaledECO2,
               humidity: avgValuesAQ.humidity,
               temperature: avgValuesAQ.temperature,
               count: count
           )
            try? await DataManager.shared.storeDailyAverageAQ(firebaseID: dateString, avgData: data)
         }
      }
      return avgValuesAQ
   }

   func computeLastHoursAverages() -> AvgValuesAQ {
      // 360 (6 samples/min* 60 min/hour) points contains the last hour of samples if sampling occurs every 10 seconds for 1 hour 
      let startIndex = max(0, aqMeasurements.count - 360)
      let relevantPoints = aqMeasurements[startIndex..<aqMeasurements.count]

      return AvgValuesAQ(
         scaledTVOC: Int(Double(relevantPoints.map { $0.scaledTVOC}.reduce(0, +)) / Double(relevantPoints.count).rounded()),
         unbiasedScaledECO2: Int(Double(relevantPoints.map { $0.unBiasedECO2AndScaled}.reduce(0, +)) / Double(relevantPoints.count).rounded()),
         temperature: Int(relevantPoints.map { $0.temperature }.reduce(0.0, +) / Double(relevantPoints.count).rounded()),
         humidity: Int(relevantPoints.map { $0.humidity }.reduce(0.0, +) / Double(relevantPoints.count).rounded())
      )
   }
   
   func computeLastHoursMaximums() -> MaxValuesAQ {
      // 360 (6 samples/min* 60 min/hour) points contains the last hour of samples if sampling occurs every 10 seconds for 1 hour
      let startIndex = max(0, aqMeasurements.count - 360)
      let relevantPoints = aqMeasurements[startIndex..<aqMeasurements.count]

      return MaxValuesAQ(
         scaledTVOC: relevantPoints.map { Int($0.scaledTVOC)}.max() ?? 0,
         unbiasedScaledECO2: relevantPoints.map { Int($0.unBiasedECO2AndScaled)}.max() ?? 0,
         temperature: relevantPoints.map { $0.temperature }.max() ?? 0.0,
         humidity: relevantPoints.map { $0.humidity }.max() ?? 0.0
      )
   }
}
