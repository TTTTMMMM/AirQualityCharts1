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
   
   private func airQualitySampleDocument(firebaseID: String) -> DocumentReference {
      return airQualityCollection.document(firebaseID)
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
   
   // function that queries by ID, puts the documents into AirQualitySample object, and returns results in array
   // the function seems to havea a limit of about 20 ids before it just craps out
   func getSamplesByID(ids: [Int]) async throws -> [AQSample] {
      var aqsArray: [AQSample] = []
      let snap = try await airQualityCollection.whereField("id", in: ids).order(by: "id").limit(to: 50).getDocuments()
      for document in snap.documents {
         aqsArray.append(try document.data(as: AQSample.self))
      }
      return(aqsArray)
   }
   
   // function that queries for on day's worth of samples, puts the documents into AirQualitySample object, and returns results in array
   // 1440 is the number of minutes in a day, just in case there is/was a problem with a runaway query as I was developing
   func getSamplesByDate(date: Date) async throws -> [AQSample] {
      var aqsArray: [AQSample] = []
      let calendar = Calendar.current
      let components = calendar.dateComponents([.year, .month, .day], from: date)
      let start = calendar.date(from: components)
      let end = calendar.date(byAdding: .day, value: 1, to: start ?? Date())
      
      let snap = try await airQualityCollection.whereField("dt", isGreaterThan: start as Any).whereField("dt", isLessThan: end as Any).order(by: "dt").limit(to: 1440).getDocuments()
      for document in snap.documents {
         aqsArray.append(try document.data(as: AQSample.self))
      }
      return(aqsArray)
   }
}
