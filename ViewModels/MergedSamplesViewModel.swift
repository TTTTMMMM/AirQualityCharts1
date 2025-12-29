//
// https://www.youtube.com/playlist?list=PLwvDm4Vfkdphl8ly0oi0aHx0v2B7UvDK0
//
import Foundation
import FirebaseFirestore
import Combine
import CryptoKit

@MainActor
final class MergedSamplesViewModel: ObservableObject {
   
   // Air Quality Fields
   var aqMeasurements: [AQSample] = []
   @Published private(set) var aqSample: AQSample? = nil
   @Published var dailyFreebiesLeft: Int? = nil
   private  var cancellablesAQ = Set<AnyCancellable>()
   private var prevCountOfAQSamples: Int = 0
   @Published var lastSampleAQ: AQSample? = nil
   @Published var numberOfSamplesRetrieved: Int? = 0
   @Published var maxValuesAQ = MaxValuesAQ()
   @Published var avgValuesAQ = AvgValuesAQ()
   @Published var maxValuesLastHourAQ = MaxValuesAQ()
   @Published var avgValuesLastHourAQ = AvgValuesAQ()
   
   // Particulate Matter Fields
   var pmMeasurements: [PMSizes] = []
   @Published private(set) var pmSizes: PMSizes? = nil
   private  var cancellablesPM = Set<AnyCancellable>()
   private var prevCountOfPMSizes: Int = 0
   @Published var lastSamplePM: PMSizes? = nil
   @Published var numberOfSamplesRetrievedPM: Int? = 0
   @Published var maxValuesPM = MaxValuesPM()
   @Published var avgValuesPM = AvgValuesPM()
   @Published var maxValuesLastHourPM = MaxValuesPM()
   @Published var avgValuesLastHourPM = AvgValuesPM()
   
   @Published var mergedData: [CombinedReading] = []
   @Published var maxValuesMerged = MaxValuesMerged()
   @Published var avgValuesMerged = AvgValuesMerged()
   @Published var maxValuesMergedLastHour = MaxValuesMerged()
   @Published var avgValuesMergedLastHour = AvgValuesMerged()
   
   enum HoursDuration: String, CaseIterable {
      case one   = "1"
      case two   = "2"
      case three = "3"
      case four  = "4"
      case five  = "5"
   }
   
   //-------------------------//
   // Methods Below           //
   //-------------------------//

   init() {
      Task {
         try? await self.getFreebiesLeft()
      }
   }
   
   // I won't be using this in the app, just here to create a test sample
   func createSampleAQ() async throws {
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
   
   // I won't be using this in the app, just here to create a test sample
   func createSamplePM() async throws {
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
   func getSampleAQ() async throws {
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
   
   // I won't be using this in the app, just here to get a test sample to see how a
   // sample comes back from Firebase
   func getSamplePM() async throws {
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
   
   func getOneDayOfSamplesAQ(date: Date) async throws {
      if let samples = try? await DataManager.shared.getSamplesByDate(
         date: date
      ) {
         try? await self.subtractFreebliesLeft(numSamplesToRemove: samples.count)
            self.numberOfSamplesRetrieved = samples.count
            self.maxValuesAQ = computeMaxValuesAQ(samples: samples)
            self.avgValuesAQ = await computeAvgValuesAQ(samples: samples, date: date, store_in_firebase: false)
         await MainActor.run {
            self.aqMeasurements = samples
         }
      }
   }
   
   func getOneDayOfSamplesPM(date: Date) async throws {
      if let samples = try? await DataManager.shared.getSamplesByDatePC(
         date: date
      ) {
         try? await self.subtractFreebliesLeft(numSamplesToRemove: samples.count)
         self.numberOfSamplesRetrieved = samples.count
         self.maxValuesPM = computeMaxValuesPM(samples: samples)
         self.avgValuesPM = await computeAvgValuesPM(samples: samples, date: date, store_in_firebase: false)
         await MainActor.run {
            self.pmMeasurements = samples
         }
      }
   }
   
   func getSecifiedHoursWorthOfSamplesAQ(date: Date, numberOfHours: Int) async throws {
      if let samples = try? await DataManager.shared.getSamplesByHour(
         date: date,
         numberOfHours: numberOfHours
      ) {
         try? await self.subtractFreebliesLeft(numSamplesToRemove: samples.count)
            self.numberOfSamplesRetrieved = samples.count
            self.maxValuesAQ = computeMaxValuesAQ(samples: samples)
            self.avgValuesAQ = await computeAvgValuesAQ(samples: samples, date: date, store_in_firebase: false)
         await MainActor.run {
            self.aqMeasurements = samples
         }
      }
   }
   
   func getSecifiedHoursWorthOfSamplesPM(date: Date, numberOfHours: Int) async throws {
      if let samples = try? await DataManager.shared.getSamplesByHourPC(
         date: date,
         numberOfHours: numberOfHours
      ) {
         try? await self.subtractFreebliesLeft(numSamplesToRemove: samples.count)
         self.numberOfSamplesRetrieved = samples.count
         self.maxValuesPM = computeMaxValuesPM(samples: samples)
         self.avgValuesPM = await computeAvgValuesPM(samples: samples, date: date, store_in_firebase: false)
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

   func addListenerForAQSamples()  {
      DataManager.shared.addListenerForAirQualitySamples()
         .sink { completion in
         } receiveValue: { [weak self] aqsArray in
            self?.aqMeasurements = aqsArray
            Task {
               await MainActor.run {
                  if let lastOne = self?.aqMeasurements.last {
                     self?.lastSampleAQ = lastOne
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
               self?.avgValuesLastHourAQ = self?.computeLastHoursAveragesAQ() ?? AvgValuesAQ(scaledTVOC: 0, unbiasedScaledECO2: 0, temperature: 0, humidity: 0)
               self?.maxValuesLastHourAQ = self?.computeLastHoursMaximumsAQ() ?? MaxValuesAQ(scaledTVOC: 0, unbiasedScaledECO2: 0, temperature: 0.0, humidity: 0.0)
               self?.avgValuesMerged = self?.deriveAvgValuesMerged(
                  avgAQ: self?.avgValuesLastHourAQ ?? AvgValuesAQ(scaledTVOC: 0, unbiasedScaledECO2: 0, temperature: 0, humidity: 0),
                  avgPM: self?.avgValuesLastHourPM ?? AvgValuesPM(pm03um: 0, pm10s: 0, pm25s: 0, pm100s: 0)
               ) ?? AvgValuesMerged(scaledTVOC: 0, unbiasedScaledECO2: 0, temperature: 0, humidity: 0, pm03um: 0, pm100s: 0)
               self?.maxValuesMerged = self?.deriveMaxValuesMerged(
                  maxAQ: self?.maxValuesLastHourAQ ?? MaxValuesAQ(scaledTVOC: 0, unbiasedScaledECO2: 0, temperature: 0.0, humidity: 0.0),
                  maxPM: self?.maxValuesLastHourPM ?? MaxValuesPM(pm03um: 0, pm10s: 0, pm25s: 0, pm100s: 0)
               ) ?? MaxValuesMerged(scaledTVOC: 0, unbiasedScaledECO2: 0, temperature: 0.0, humidity: 0.0, pm03um: 0, pm100s: 0)
            }
            self?.mergeData()
         }
         // don't forget to store in cancellables, so we can remove listener when we're done
         .store(in: &cancellablesAQ)
   }
   
   func addListenerForParticleCountsSizes()  {
      DataManager.shared.addListenerForParticleCountsSamples()
         .sink { completion in
         } receiveValue: { [weak self] particleSizeCountsArray in
            self?.pmMeasurements = particleSizeCountsArray
            Task {
               await MainActor.run {
                  if let lastOne = self?.pmMeasurements.last {
                     self?.lastSamplePM = lastOne
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
               self?.avgValuesLastHourPM = self?.computeLastHoursAveragesPM() ?? AvgValuesPM(pm03um: 0, pm10s: 0, pm25s: 0, pm100s: 0)
               self?.maxValuesLastHourPM = self?.computeLastHoursMaximumsPM() ?? MaxValuesPM(pm03um: 0, pm10s: 0, pm25s: 0, pm100s: 0)
            }
         }
      // don't forget to store in cancellables, so we can remove listener when we're done
         .store(in: &cancellablesPM)
   }
   
   func cancelCombineSubscriptionsAQ()  {
      cancellablesAQ.removeAll()
      }
   
   func cancelCombineSubscriptionsPM()  {
      cancellablesPM.removeAll()
   }

   func computeMaxValuesAQ(samples: [AQSample]) -> MaxValuesAQ {
      return MaxValuesAQ(
         scaledTVOC: samples.map { Int($0.scaledTVOC)}.max() ?? 0,
         unbiasedScaledECO2: samples.map { Int($0.unBiasedECO2AndScaled)}.max() ?? 0,
         temperature: samples.map { $0.temperature }.max() ?? 0.0,
         humidity: samples.map { $0.humidity }.max() ?? 0.0
      )
   }
   
   func computeMaxValuesPM(samples: [PMSizes]) -> MaxValuesPM {
      return MaxValuesPM(
         pm03um: samples.map { $0.pm03um }.max() ?? 0,
         pm10s: samples.map { $0.pm10s }.max() ?? 0,
         pm25s: samples.map { $0.pm25s }.max() ?? 0,
         pm100s: samples.map { $0.pm100s }.max() ?? 0
      )
   }

   func computeAvgValuesAQ(samples: [AQSample], date: Date, store_in_firebase: Bool = false) async -> AvgValuesAQ {
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

   func computeAvgValuesPM(samples: [PMSizes], date: Date, store_in_firebase: Bool = false) async -> AvgValuesPM {
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
   
   func deriveAvgValuesMerged(avgAQ: AvgValuesAQ, avgPM: AvgValuesPM) -> AvgValuesMerged {
      let avgM = AvgValuesMerged(
         scaledTVOC: avgAQ.scaledTVOC,
         unbiasedScaledECO2: avgAQ.unbiasedScaledECO2,
         temperature: avgAQ.temperature,
         humidity: avgAQ.humidity,
         pm03um: avgPM.pm03um,
         pm100s: avgPM.pm100s
         )
      return avgM
   }
   
   func deriveMaxValuesMerged(maxAQ: MaxValuesAQ, maxPM: MaxValuesPM) -> MaxValuesMerged {
      let maxM = MaxValuesMerged(
         scaledTVOC: maxAQ.scaledTVOC,
         unbiasedScaledECO2: maxAQ.unbiasedScaledECO2,
         temperature: maxAQ.temperature,
         humidity: maxAQ.humidity,
         pm03um: maxPM.pm03um,
         pm100s: maxPM.pm100s
         )
      return maxM
   }

   func computeLastHoursAveragesAQ() -> AvgValuesAQ {
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

   func computeLastHoursAveragesPM() -> AvgValuesPM {
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

   func computeLastHoursMaximumsAQ() -> MaxValuesAQ {
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

   func computeLastHoursMaximumsPM() -> MaxValuesPM {
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

   private func roundSamplesToTenSecondsAQ(_ samples: [AQSample]) -> [AQSample] {
       return samples.map { sample in
           // 1. Get the raw seconds value
           let timeInterval = sample.dt.timeIntervalSinceReferenceDate
           
           // 2. Round to the nearest 10 (divide by 10, round, then multiply back)
           let roundedInterval = (timeInterval / 10.0).rounded(.toNearestOrAwayFromZero) * 10.0
           
           // 3. Create a new Date object from the rounded interval
           let roundedDate = Date(timeIntervalSinceReferenceDate: roundedInterval)
           
           // 4. Return a copy of the sample with the updated 'dt' field
           var updatedSample = sample
           updatedSample.dt = roundedDate
           return updatedSample
       }
   }
   
   private func roundSamplesToTenSecondsPM(_ samples: [PMSizes]) -> [PMSizes] {
       return samples.map { sample in
           // 1. Get the raw seconds value
           let timeInterval = sample.dt.timeIntervalSinceReferenceDate
           
           // 2. Round to the nearest 10 (divide by 10, round, then multiply back)
           let roundedInterval = (timeInterval / 10.0).rounded(.toNearestOrAwayFromZero) * 10.0
           
           // 3. Create a new Date object from the rounded interval
           let roundedDate = Date(timeIntervalSinceReferenceDate: roundedInterval)
           
           // 4. Return a copy of the sample with the updated 'dt' field
           var updatedSample = sample
           updatedSample.dt = roundedDate
           return updatedSample
       }
   }
      
   func mergeData() {
      let rounded10secAQ = roundSamplesToTenSecondsAQ(self.aqMeasurements)
      let rounded10secPM = roundSamplesToTenSecondsPM(self.pmMeasurements)
      
      var merged: [CombinedReading] = []
      var aqIdx = 0
      var pmIdx = 0
      var g_old: AQSample = AQSample(id: 123456, tVOC: 0, dt: Date(),  eCO2: 0, humidity: 0.0, temperature: 0.0)
      var p_old: PMSizes = PMSizes(id: 654321, dt: Date(), pm03um: 0, pm10s: 0, pm25s: 0, pm100s: 0)
      var p = p_old
      
      while aqIdx < rounded10secAQ.count || pmIdx < rounded10secPM.count {
         // Case A: Only AQ readings left
         if pmIdx >= rounded10secPM.count {
            let g = rounded10secAQ[aqIdx]
            if (rounded10secPM.count > 0) {
               p = rounded10secPM[pmIdx-1]  // previous sample carries forward
            }
            merged.append(
               CombinedReading(
                  dt: g.dt,
                  aqId: g.id,
                  tVOC: g.tVOC,
                  eCO2: g.eCO2,
                  humidity: g.humidity,
                  temperature: g.temperature,
                  pmId: p.id,
                  pm03um: p.pm03um,
                  pm100s: p.pm100s
               ))
            aqIdx += 1
            continue
         }
         
         // Case B: Only PM readings left
         if aqIdx >= rounded10secAQ.count {
            let p = rounded10secPM[pmIdx]
            let g = rounded10secAQ[aqIdx-1]   // previous sample carries forward
            merged.append(
               CombinedReading(
                  dt: g.dt,
                  aqId: g.id,
                  tVOC: g.tVOC,
                  eCO2: g.eCO2,
                  humidity: g.humidity,
                  temperature: g.temperature,
                  pmId: p.id,
                  pm03um: p.pm03um,
                  pm100s: p.pm100s
               ))
            pmIdx += 1
            continue
         }
         
         let g = rounded10secAQ[aqIdx]
         let p = rounded10secPM[pmIdx]
         let diff = abs(g.dt.timeIntervalSince(p.dt))
         
         if diff <= 5.0 {
            // Case C: Within 5 seconds - Combine them
            merged.append(
               CombinedReading(
               dt: g.dt, // Use gas timestamp as anchor
               aqId: g.id,
               tVOC: g.tVOC,
               eCO2: g.eCO2,
               humidity: g.humidity,
               temperature: g.temperature,
               pmId: p.id,
               pm03um: p.pm03um,
               pm100s: p.pm100s
            ))
            aqIdx += 1
            pmIdx += 1
            g_old = g                 // will become previous sample
            p_old = p                 // will become previous sample
         } else if g.dt < p.dt {
            // Case D: AQ reading is earlier and not matched
            merged.append(
               CombinedReading(
                  dt: g.dt,
                  aqId: g.id,
                  tVOC: g.tVOC,
                  eCO2: g.eCO2,
                  humidity: g.humidity,
                  temperature: g.temperature,
                  pmId: p_old.id,              // previous sample carries forward
                  pm03um: p_old.pm03um,        // previous sample carries forward
                  pm100s: p_old.pm100s         // previous sample carries forward
               ))
            aqIdx += 1
         } else {
            // Case E: PM reading is earlier and not matched
            merged.append(
               CombinedReading(
                  dt: p.dt,
                  aqId: g_old.id,                  // previous sample carries forward
                  tVOC: g_old.tVOC,                // previous sample carries forward
                  eCO2: g_old.eCO2,                // previous sample carries forward
                  humidity: g_old.humidity,        // previous sample carries forward
                  temperature: g_old.temperature,  // previous sample carries forward
                  pmId: p.id,
                  pm03um: p.pm03um,
                  pm100s: p.pm100s
               ))
            pmIdx += 1
         }
      }
//      print("\n******* Merged Data (last 10) ********")
//      let lastTenElements = self.mergedData.suffix(10)
//      for (offset, value) in lastTenElements.enumerated() {
//         let originalIndex = self.mergedData.count - lastTenElements.count + offset
//         print("\(originalIndex): \(value)")
//      }
//      self.mergedData = Array(merged.dropLast())
      Task {
         await MainActor.run {
            self.mergedData = merged
         }
      }
   }
}
