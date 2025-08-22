//
// https://www.youtube.com/playlist?list=PLwvDm4Vfkdphl8ly0oi0aHx0v2B7UvDK0
// Specifically, Fetching Firebase Firestore data with Codable in Swift | Firebase Bootcamp #10
//
import Foundation
import FirebaseFirestore
import FirebaseSharedSwift
import Combine

final class AirQualityDataManager {
   
   static let shared = AirQualityDataManager()
   private init() {}
   
   private let airQualityCollection = Firestore.firestore().collection("air_quality")
   private let freebiesLeftCollection = Firestore.firestore().collection("freebies_left")
   
   private var airQualitySampleListener : ListenerRegistration? = nil
   
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
   
   func getAQSample(firebaseID: String) async throws -> AQSample {
      // next line directly decodes from firebase document to an
      // airquality sample type and returns it
      try await airQualitySampleDocument(firebaseID: firebaseID).getDocument(
         as: AQSample.self
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
   
   // function that queries for one day's worth of samples,
   // puts the documents into AirQualitySample object, and returns results in array
   // 8640 is the number of minutes in a day*6, just in case there is/was a
   // problem with a runaway-query as I was developing
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
   
   // function that queries for a specified number of hour's [1..8] worth
   // of samples, puts the documents into AirQualitySample object, and
   // returns results in an array
   // 480*6 is the number of minutes in an an 8-hour window, just in case there
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
//      let start = calendar.date(byAdding: .hour, value: -2, to: Date())
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
   
}
