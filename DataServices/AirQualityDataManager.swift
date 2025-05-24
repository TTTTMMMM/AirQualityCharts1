//
// https://www.youtube.com/playlist?list=PLwvDm4Vfkdphl8ly0oi0aHx0v2B7UvDK0
// Specifically, Fetching Firebase Firestore data with Codable in Swift | Firebase Bootcamp #10
//
import Foundation
import FirebaseFirestore
import FirebaseSharedSwift

final class AirQualityDataManager {
   
   static let shared = AirQualityDataManager()
   private init() {}
   
   private let airQualityCollection = Firestore.firestore().collection("air_quality")
   private let freebiesLeftCollection = Firestore.firestore().collection("freebies_left")
   
   private func airQualitySampleDocument(firebaseID: String) -> DocumentReference {
      return airQualityCollection.document(firebaseID)
   }
   
   private func freebiesDocument() -> DocumentReference {
      return freebiesLeftCollection.document("freebies")  // only one document is in this collection
   }
   
   func createSample(firebaseID: String, aqSample: AQSample) async throws {
      try airQualitySampleDocument(firebaseID: firebaseID).setData(from: aqSample, merge: false)
   }
   
   func getAQSample(firebaseID: String) async throws -> AQSample {
      // next line directly decodes from firebase document to an airquality sample type and returns it
      try await airQualitySampleDocument(firebaseID: firebaseID).getDocument(as: AQSample.self)
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
   // 1440 is the number of minutes in a day, just in case there is/was a
   // problem with a runaway-query as I was developing
   func getSamplesByDate(date: Date) async throws -> [AQSample] {
      var aqsArray: [AQSample] = []
      let calendar = Calendar.current
      let components = calendar.dateComponents([.year, .month, .day], from: date)
      let start = calendar.date(from: components)
      let end = calendar.date(byAdding: .day, value: 1, to: start ?? Date())
      
      let snap = try await airQualityCollection.whereField(
         AQSample.CodingKeys.dt.stringValue,
         isGreaterThan: start as Any).whereField(AQSample.CodingKeys.dt.stringValue,
            isLessThan: end as Any).order(by: AQSample.CodingKeys.dt.stringValue).limit(to: 1440).getDocuments()
      for document in snap.documents {
         aqsArray.append(try document.data(as: AQSample.self))
      }
      return(aqsArray)
   }
   
   // function that queries for one hour's worth of samples, puts the
   // documents into AirQualitySample object, and returns results in array
   // 480 is the number of minutes in an an 8-hour window, just in case there
   // is/was a problem with a runaway query as I was developing
   func getSamplesByHour(date: Date, numberOfHours: Int) async throws -> [AQSample] {
      var aqsArray: [AQSample] = []
      let calendar = Calendar.current
      let components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
      let start = calendar.date(from: components)
      let end = calendar.date(byAdding: .hour, value: numberOfHours, to: start ?? Date())
      
      let snap = try await airQualityCollection.whereField(AQSample.CodingKeys.dt.stringValue,
            isGreaterThan: start as Any).whereField(AQSample.CodingKeys.dt.stringValue,
            isLessThan: end as Any).order(by: AQSample.CodingKeys.dt.stringValue).limit(to: 480).getDocuments()
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
   
}
