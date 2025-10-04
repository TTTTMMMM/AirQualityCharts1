//
// https://www.youtube.com/playlist?list=PLwvDm4Vfkdphl8ly0oi0aHx0v2B7UvDK0
// Specifically, Fetching Firebase Firestore data with Codable in Swift | Firebase Bootcamp #10
//
import Foundation
import FirebaseFirestore
import FirebaseSharedSwift
import Combine

final class DataManager {
   
   static let shared = DataManager()
   private init() {}
   
   private let airQualityCollection = Firestore.firestore().collection("air_quality")
   private let particleCountsCollection = Firestore.firestore().collection("particle_counts")
   private let freebiesLeftCollection = Firestore.firestore().collection("freebies_left")
//   private let dailyAverageAQCollection = Firestore.firestore().collection("daily_averagesAQ")
//   private let dailyAveragePMCollection = Firestore.firestore().collection("daily_averagesPM")
   private let xBarAQCollection = Firestore.firestore().collection("daily_averagesAQ")
   private let xBarPMCollection = Firestore.firestore().collection("daily_averagesPM")


   private var airQualitySampleListener : ListenerRegistration? = nil
   private var particleCountsListener : ListenerRegistration? = nil

   private func getRoundedDateTwoHoursAgo() -> Date {
       let now = Date()
       let twoHoursAgo = now.addingTimeInterval(-2 * 60 * 60) // Subtract 2 hours (in seconds)

       let calendar = Calendar.current
       let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: twoHoursAgo)

       guard let hour = components.hour, let minute = components.minute else {
           return twoHoursAgo // Fallback if components are not available
       }

       // Calculate total minutes from the beginning of the day for rounding
       let totalMinutes = hour * 60 + minute

       // Determine the nearest 15-minute interval
       let roundedMinutes = Int(round(Double(totalMinutes) / 15.0)) * 15

       // Reconstruct the date with the rounded minutes
       var newComponents = DateComponents()
       newComponents.year = components.year
       newComponents.month = components.month
       newComponents.day = components.day
       newComponents.hour = roundedMinutes / 60
       newComponents.minute = roundedMinutes % 60
       newComponents.second = 0 // Set seconds to 0 for consistent rounding

       return calendar.date(from: newComponents) ?? twoHoursAgo // Fallback if date cannot be created
   }

   
   private func airQualitySampleDocument(firebaseID: String) -> DocumentReference {
      return airQualityCollection.document(firebaseID)
   }
   
   private func particleCountDocument(firebaseID: String) -> DocumentReference {
      return particleCountsCollection.document(firebaseID)
   }
   
   private func freebiesDocument() -> DocumentReference {
      // only one document is in this collection
      return freebiesLeftCollection.document("freebies")
   }
   
   func createSample(firebaseID: String, aqSample: AQSample) async throws {
      try airQualitySampleDocument(firebaseID: firebaseID).setData(
         from: aqSample,
         merge: false
      )
   }
   
   func createSamplePC(firebaseID: String, PMSizes: PMSizes) async throws {
      try particleCountDocument(firebaseID: firebaseID).setData(
         from: PMSizes,
         merge: false
      )
   }
   
   func getAQSample(firebaseID: String) async throws -> AQSample {
      // next line directly decodes from firebase document to an
      // airquality sample type and returns it
      try await airQualitySampleDocument(firebaseID: firebaseID).getDocument(
         as: AQSample.self
      )
   }
   
   func getPCSample(firebaseID: String) async throws -> PMSizes {
      // next line directly decodes from firebase document to an
      // PMSizes sample type and returns it
      try await particleCountDocument(firebaseID: firebaseID).getDocument(
         as: PMSizes.self
      )
   }
   
   // the following function updates only the 'cause' property of an
   // air quality sample in the firebase firestore db
   func updateCause(firebaseID: String, reason: String?) async throws {
      let data: [String:Any] = [   // create a dictionary
         AQSample.CodingKeys.cause.stringValue : reason ?? nil
      ]
      try await airQualitySampleDocument(firebaseID: firebaseID).updateData(data)
   }
   
   // function that queries for one day's worth of air quality samples,
   // puts the documents into PMSizes object, and returns results in array
   // 8640 = (1440 minutes/day * 6 samples/minute) when sampling the sensor
   // 6 times a minute, just in case there is/was a problem with a
   // runaway-query as I was developing
   func getSamplesByDate(date: Date) async throws -> [AQSample] {
      var aqsArray: [AQSample] = []
      let calendar = Calendar.current
      let components = calendar.dateComponents([.year, .month, .day], from: date)
      let start = calendar.date(from: components)
      let end = calendar.date(byAdding: .day, value: 1, to: start ?? Date())
      
      let snap = try await airQualityCollection.whereField(
         AQSample.CodingKeys.dt.stringValue,
         isGreaterThan: start as Any
      ).whereField(AQSample.CodingKeys.dt.stringValue,
                   isLessThan: end as Any
      ).order(
         by: AQSample.CodingKeys.dt.stringValue
      ).limit(to: 8640).getDocuments()
      for document in snap.documents {
         aqsArray.append(try document.data(as: AQSample.self))
      }
      return(aqsArray)
   }
   
   // function that queries for one day's worth of particle_counts,
   // puts the documents into PMSizes object, and returns results in array
   // 8640 = (1440 minutes/day * 6 samples/minute) when sampling the sensor
   // 6 times a minute, just in case there is/was a problem with a
   // runaway-query as I was developing
   func getSamplesByDatePC(date: Date) async throws -> [PMSizes] {
      var pcsArray: [PMSizes] = []
      let calendar = Calendar.current
      let components = calendar.dateComponents([.year, .month, .day], from: date)
      let start = calendar.date(from: components)
      let end = calendar.date(byAdding: .day, value: 1, to: start ?? Date())
      
      let snap = try await particleCountsCollection.whereField(
         PMSizes.CodingKeys.dt.stringValue,
         isGreaterThan: start as Any
      ).whereField(PMSizes.CodingKeys.dt.stringValue,
                   isLessThan: end as Any
      ).order(
         by: PMSizes.CodingKeys.dt.stringValue
      ).limit(to: 8640).getDocuments()
      for document in snap.documents {
         pcsArray.append(try document.data(as: PMSizes.self))
      }
      return(pcsArray)
   }
   
   // function that queries for a specified number of hour's [1..8] worth
   // of samples, puts the documents into AirQualitySample object, and
   // returns results in an array
   // 2880 = 480 minutes/8-hour window * 6 samples/minute is the number of samples in
   // an an 8-hour window, just in case there
   // is/was a problem with a runaway query as I was developing
   func getSamplesByHour(date: Date, numberOfHours: Int) async throws -> [AQSample] {
      var aqsArray: [AQSample] = []
      let calendar = Calendar.current
      let components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
      let start = calendar.date(from: components)
      let end = calendar.date(byAdding: .hour, value: numberOfHours, to: start ?? Date())
      
      let snap = try await airQualityCollection.whereField(
         AQSample.CodingKeys.dt.stringValue,
         isGreaterThan: start as Any
      ).whereField(AQSample.CodingKeys.dt.stringValue,
                   isLessThan: end as Any
      ).order(
         by: AQSample.CodingKeys.dt.stringValue
      ).limit(to: 2880).getDocuments()
      for document in snap.documents {
         aqsArray.append(try document.data(as: AQSample.self))
      }
      return(aqsArray)
   }
   
   // function that queries for a specified number of hour's [1..8] worth
   // of samples, puts the documents into PMSizes object, and
   // returns results in an array
   // 2880 = 480 minutes/8-hour window * 6 samples/minute is the number of samples in
   // an an 8-hour window, just in case there
   // is/was a problem with a runaway query as I was developing
   func getSamplesByHourPC(date: Date, numberOfHours: Int) async throws -> [PMSizes] {
      var pcsArray: [PMSizes] = []
      let calendar = Calendar.current
      let components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
      let start = calendar.date(from: components)
      let end = calendar.date(byAdding: .hour, value: numberOfHours, to: start ?? Date())
      
      let snap = try await particleCountsCollection.whereField(
         PMSizes.CodingKeys.dt.stringValue,
         isGreaterThan: start as Any
      ).whereField(PMSizes.CodingKeys.dt.stringValue,
                   isLessThan: end as Any
      ).order(
         by: PMSizes.CodingKeys.dt.stringValue
      ).limit(to: 2880).getDocuments()
      for document in snap.documents {
         pcsArray.append(try document.data(as: PMSizes.self))
      }
      return(pcsArray)
   }
   
   func getNumFreebies() async throws -> Freebies {
      let freebies = try await freebiesDocument().getDocument(as: Freebies.self)
      return freebies
   }
   
   func setNumFreebies(freebies: Freebies) async throws -> () {
      try  freebiesDocument().setData(from: freebies)
   }
   
   // function that sets up a Firestore listener for real-time data,
   // starting a couple of hours back from now.
   // could not have done this func without following along with
   // https://www.youtube.com/watch?v=a87MFlvfWvA&list=PLwvDm4Vfkdphl8ly0oi0aHx0v2B7UvDK0&index=17
   // Note that this uses the Combine framework, not async-await, because
   // Firebase does not have an async-await method for adding a listener (yet?)
   
   func addListenerForAirQualitySamples() -> AnyPublisher<[AQSample], Error> {
      let publisher = PassthroughSubject<[AQSample], Error>()
      let calendar = Calendar.current
      let start = getRoundedDateTwoHoursAgo()
      
      self.airQualitySampleListener = airQualityCollection.whereField(
         AQSample.CodingKeys.dt.stringValue,isGreaterThan: start as Any)
      .addSnapshotListener { querySnapshot, error in
         guard let documents = querySnapshot?.documents else {
            print("No samples")
            return
         }
         let aqsArray: [AQSample] = documents.compactMap({try? $0.data(as: AQSample.self)})
         publisher.send(aqsArray)
      }
      return publisher.eraseToAnyPublisher()
   }
   
   // function that sets up a Firestore listener for real-time data,
   // starting a couple of hours back from now.
   // could not have done this func without following along with
   // https://www.youtube.com/watch?v=a87MFlvfWvA&list=PLwvDm4Vfkdphl8ly0oi0aHx0v2B7UvDK0&index=17
   // Note that this uses the Combine framework, not async-await, because
   // Firebase does not have an async-await method for adding a listener (yet?)
   
   func addListenerForParticleCountsSamples() -> AnyPublisher<[PMSizes], Error> {
      let publisher = PassthroughSubject<[PMSizes], Error>()
      let calendar = Calendar.current
      let start = getRoundedDateTwoHoursAgo()
      
      self.particleCountsListener = self.particleCountsCollection.whereField(
         PMSizes.CodingKeys.dt.stringValue,isGreaterThan: start as Any)
      .addSnapshotListener { querySnapshot, error in
         guard let documents = querySnapshot?.documents else {
            print("No samples")
            return
         }
         let pcsArray: [PMSizes] = documents.compactMap({try? $0.data(as: PMSizes.self)})
         publisher.send(pcsArray)
      }
      return publisher.eraseToAnyPublisher()
   }
   
   //-----------
   private func dailyAverageAQDocument(firebaseID: String) -> DocumentReference {
      return xBarAQCollection.document(firebaseID)
   }
   
   func createDailyAverageAQ(firebaseID: String, avgData: XBarAQ) async throws {
      try dailyAverageAQDocument(firebaseID: firebaseID).setData(
         from: avgData,
         merge: false
      )
   }
   
   //-----------
   private func dailyAveragePMDocument(firebaseID: String) -> DocumentReference {
      return xBarPMCollection.document(firebaseID)
   }
   
   func createDailyAveragePM(firebaseID: String, avgData: XBarPM) async throws {
      try dailyAveragePMDocument(firebaseID: firebaseID).setData(
         from: avgData,
         merge: false
      )
   }
   
   // function that queries for all AQ dailyAverages with beginning and end dates as params,
   // puts the documents into PMSizes object, and returns results in array
   // 1830 = (365 days/year * 5 years), the amount of time the daily averages will exist
   // before automatic deletion by Firebase based on the ttl field I gave each document
   // in the collection
   func getXBarAQ(startingFrom: Date, endingAt: Date = Date()) async throws -> [XBarAQ] {
      var xBarAQArray: [XBarAQ] = []
      let calendar = Calendar.current
      // trying to compensate for some timezone nonsense, which eludes me
      guard let start = calendar.date(byAdding: .day, value: -1, to: startingFrom) else {
          fatalError("Could not calculate the previous day from startingFrom \(String(describing: startingFrom)).")
      }
      guard let end = calendar.date(byAdding: .day, value: -1, to: endingAt) else {
          fatalError("Could not calculate the previous day from startingFrom \(String(describing: endingAt)).")
      }

      print("--> start: \(String(describing: start)), end: \(String(describing: end))")
      let snap = try await xBarAQCollection.whereField(
         XBarAQ.CodingKeys.dt.stringValue,
         isGreaterThan: start as Any
      ).whereField(
         XBarAQ.CodingKeys.dt.stringValue,
         isLessThan: end as Any
      ).order(
         by: XBarAQ.CodingKeys.dt.stringValue
      ).limit(to: 1830).getDocuments()
      for document in snap.documents {
         xBarAQArray.append(try document.data(as: XBarAQ.self))
      }
      return(xBarAQArray)
   }
   
   // function that queries for all PM dailyAverages with beginning and end dates as params,
   // puts the documents into PMSizes object, and returns results in array
   // 1830 = (365 days/year * 5 years), the amount of time the daily averages will exist
   // before automatic deletion by Firebase based on the ttl field I gave each document
   // in the collection
   func getXBarPM(startingFrom: Date, endingAt: Date = Date()) async throws -> [XBarPM] {
      var XBarPMArray: [XBarPM] = []
      let calendar = Calendar.current
      let componentsStart = calendar.dateComponents([.year, .month, .day], from: startingFrom)
      let start = calendar.date(from: componentsStart)
      let componentsEnd = calendar.dateComponents([.year, .month, .day], from: endingAt)
      let end = calendar.date(from: componentsEnd) ?? Date()
      
      let snap = try await xBarAQCollection.whereField(
         XBarPM.CodingKeys.dt.stringValue,
            isGreaterThanOrEqualTo: start as Any
      ).whereField(
         XBarPM.CodingKeys.dt.stringValue,
         isLessThanOrEqualTo: end as Any
      ).order(
         by: XBarPM.CodingKeys.dt.stringValue
      ).limit(to: 1830).getDocuments()
      for document in snap.documents {
         XBarPMArray.append(try document.data(as: XBarPM.self))
      }
      return(XBarPMArray)
   }
   
}
