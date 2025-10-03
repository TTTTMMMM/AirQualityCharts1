//
// https://www.youtube.com/playlist?list=PLwvDm4Vfkdphl8ly0oi0aHx0v2B7UvDK0
//
import Foundation
import FirebaseFirestore
import Combine
import CryptoKit

@MainActor
class ParticleCountsViewModel: ObservableObject {
   
   @Published var pmMeasurements: [PMSizes] = []
   @Published private(set) var pmSizes: PMSizes? = nil
   @Published var dailyFreebiesLeft: Int? = nil
   private  var cancellables = Set<AnyCancellable>()
   private var prevCountOfPMSizes: Int = 0
   @Published var lastSample: PMSizes? = nil
   @Published var numberOfSamplesRetrieved: Int? = 0
   @Published var maxValues = MaxValuesPM()
   @Published var avgValues = AvgValuesPM()
   @Published var maxValuesLastHour = MaxValuesPM()
   @Published var avgValuesLastHour = AvgValuesPM()
   
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
      let firebaseID = "0000z98Niiq0x5tdWD41"
      let pmSizes = PMSizes(
         id: 3698,
         dt: Date(),
         pm03um: 4789,
         pm10s: 25,
         pm25s: 38,
         pm100s: 40
      )
      
      try? await DataManager.shared.createSamplePC(
         firebaseID: firebaseID,
         PMSizes: pmSizes
      )
   }
   
   // I won't be using this in the app, just here to get a test sample to see how a
   // sample comes back from Firebase
   func getSample() async throws {
      let firebaseID = "01JeagbwvYpuFDGUqzKZ"
      let pms = try await DataManager.shared.getPCSample(
         firebaseID: firebaseID
      )
      await MainActor.run {
         self.pmSizes = pms
         print("\(firebaseID) -> \(self.pmSizes.debugDescription)")
         let ds = self.pmSizes?.dateString ?? "nil"
         let ts = self.pmSizes?.timeString ?? "nil"
         print("\(ds)")
         print("\(ts)")
      }
   }
   
   func getOneDayOfSamples(date: Date) async throws {
      if let samples = try? await DataManager.shared.getSamplesByDatePC(
         date: date
      ) {
         try? await self.subtractFreebliesLeft(numSamplesToRemove: samples.count)
         self.numberOfSamplesRetrieved = samples.count
         self.maxValues = computeMaxValues(samples: samples)
         self.avgValues = await computeAvgValues(samples: samples, date: date, store_in_firebase: true)
         await MainActor.run {
            self.pmMeasurements = samples
         }
      }
   }
   
   func getSecifiedHoursWorthOfSamples(date: Date, numberOfHours: Int) async throws {
      if let samples = try? await DataManager.shared.getSamplesByHourPC(
         date: date,
         numberOfHours: numberOfHours
      ) {
         try? await self.subtractFreebliesLeft(numSamplesToRemove: samples.count)
         self.numberOfSamplesRetrieved = samples.count
         self.maxValues = computeMaxValues(samples: samples)
         self.avgValues = await computeAvgValues(samples: samples, date: date, store_in_firebase: false)
         await MainActor.run {
            self.pmMeasurements = samples
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
   
   func addListenerForParticleCountsSizes()  {
      DataManager.shared.addListenerForParticleCountsSamples()
         .sink { completion in
         } receiveValue: { [weak self] particleSizeCountsArray in
            self?.pmMeasurements = particleSizeCountsArray
            Task {
               await MainActor.run {
                  if let lastOne = self?.pmMeasurements.last {
                     self?.lastSample = lastOne
                  }
               }
               // let's adjust the numFreebies left (+1 in the realCount
               // refers to the read of numFreebies from Firestore to
               // get the current count and then the read to verify after I subtract)
               if let count = self?.pmMeasurements.count {
                  if let prevCount = self?.prevCountOfPMSizes {
                     let realCount = count - prevCount
                     try? await self?.subtractFreebliesLeft(numSamplesToRemove: realCount + 1)
                     self?.prevCountOfPMSizes = prevCount + realCount
                  }
               }
               self?.avgValuesLastHour = self?.computeLastHoursAverages() ?? AvgValuesPM(pm03um: 0, pm10s: 0, pm25s: 0, pm100s: 0)
               self?.maxValuesLastHour = self?.computeLastHoursMaximums() ?? MaxValuesPM(pm03um: 0, pm10s: 0, pm25s: 0, pm100s: 0)
            }
         }
      // don't forget to store in cancellables, so we can remove listener when we're done
         .store(in: &cancellables)
   }
   
   func cancelCombineSubscriptions()  {
      cancellables.removeAll()
   }
   
   func computeMaxValues(samples: [PMSizes]) -> MaxValuesPM {
      return MaxValuesPM(
         pm03um: samples.map { $0.pm03um }.max() ?? 0,
         pm10s: samples.map { $0.pm10s }.max() ?? 0,
         pm25s: samples.map { $0.pm25s }.max() ?? 0,
         pm100s: samples.map { $0.pm100s }.max() ?? 0
      )
   }
   
   func computeAvgValues(samples: [PMSizes], date: Date, store_in_firebase: Bool = false) async -> AvgValuesPM {
      let avgValuesPM = AvgValuesPM(
         pm03um: Int(Double(samples.map { $0.pm03um }.reduce(0, +)) / Double(samples.count).rounded()),
         pm10s: Int(Double(samples.map { $0.pm10s }.reduce(0, +)) / Double(samples.count).rounded()),
         pm25s: Int(Double(samples.map { $0.pm25s }.reduce(0, +)) / Double(samples.count).rounded()),
         pm100s: Int(Double(samples.map { $0.pm100s }.reduce(0, +)) / Double(samples.count).rounded())
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
            guard let startOfDay = calendar.date(from: components) else { return avgValuesPM }
            let combinedString = "\(dateString)_\(avgValuesPM.pm03um)-\(avgValuesPM.pm10s)-\(avgValuesPM.pm25s)-\(avgValuesPM.pm100s)-\(count)"
            let dataCombinedString = Data(combinedString.utf8)
            let hash = SHA256.hash(data: dataCombinedString)
            let hashString = hash.compactMap { String(format: "%02x", $0) }.joined()
            let index = hashString.index(hashString.startIndex, offsetBy: 11)
            let truncHash = String(hashString.prefix(upTo: index))

            let data = XBarPM(
               id: truncHash,
               dt: startOfDay,
               ttl: ttl,
               pm03um: avgValuesPM.pm03um,
               pm100s: avgValuesPM.pm100s,
               pm10s: avgValuesPM.pm10s,
               pm25s: avgValuesPM.pm25s,
               count: count
           )
            try? await DataManager.shared.createDailyAveragePM(firebaseID: dateString, avgData: data)
         }
      }
      return avgValuesPM
   }
   
   func computeLastHoursAverages() -> AvgValuesPM {
      // 360 (6 samples/min* 60 min/hour) points contains the last hour of samples if sampling occurs every 10 seconds for 1 hour
      let startIndex = max(0, pmMeasurements.count - 360)
      let relevantPoints = pmMeasurements[startIndex..<pmMeasurements.count]
      
      return AvgValuesPM(
         pm03um: Int(Double(relevantPoints.map { $0.pm03um}.reduce(0, +)) / Double(relevantPoints.count).rounded()),
         pm10s:  Int(Double(relevantPoints.map { $0.pm10s}.reduce(0, +)) / Double(relevantPoints.count).rounded()),
         pm25s:  Int(Double(relevantPoints.map { $0.pm25s }.reduce(0, +)) / Double(relevantPoints.count).rounded()),
         pm100s: Int(Double(relevantPoints.map { $0.pm100s }.reduce(0, +)) / Double(relevantPoints.count).rounded())
      )
   }
   
   func computeLastHoursMaximums() -> MaxValuesPM {
      // 360 (6 samples/min* 60 min/hour) points contains the last hour of samples if sampling occurs every 10 seconds for 1 hour
      let startIndex = max(0, pmMeasurements.count - 360)
      let relevantPoints = pmMeasurements[startIndex..<pmMeasurements.count]

      return MaxValuesPM(
         pm03um: relevantPoints.map { Int($0.pm03um)}.max() ?? 0,
         pm10s: relevantPoints.map { Int($0.pm10s)}.max() ?? 0,
         pm25s: relevantPoints.map { $0.pm25s }.max() ?? 0,
         pm100s: relevantPoints.map { $0.pm100s }.max() ?? 0
      )
   }
   
}
