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
      //      0046sa5vLc00OjjKPIGD ->
      //      AirQualityCharts.AQSample(
      //      id: 46015,
      //      TVOC: 11,
      //      dt: 2025-05-18 22:27:00 +0000,
      //      eCO2: 400,
      //      forwarder: Optional("forwarder_NAS-220P"),
      //      humidity: 40.6,
      //      temperature: 78.5)
      // next line directly decodes from firebase document to an airquality sample type and returns it

      try await airQualitySampleDocument(firebaseID: firebaseID).getDocument(as: AQSample.self)
   }
   
   static let mockDataDay1: [AQSample] = [
      AQSample(
         id: 23904,
         TVOC: 50,
         dt: Date(),
         eCO2: 721,
         forwarder: "forwarder_NAS-220P",
         humidity: 28.9,
         temperature: 78.9
      ),
      AQSample(
         id: 23905,
         TVOC: 100,
         dt: Date(),
         eCO2: 761,
         forwarder: "forwarder_NAS-220P",
         humidity: 42.0,
         temperature: 78.8
      )
   ]
   
   static let mockDataDay2: [AQSample] = [
      AQSample(
         id: 34230,
         TVOC: 208,
         dt: Date(),
         eCO2: 641,
         forwarder: "forwarder_NAS-220P",
         humidity: 46.4,
         temperature: 74.4
      ),
      AQSample(
         id: 34231,
         TVOC: 216,
         dt: Date(),
         eCO2: 642,
         forwarder: "forwarder_NAS-220P",
         humidity: 46.3,
         temperature: 74.5
      )
   ]
//   static let mockDataDay1: [AQSample] = [
//      AQSample(
//         id: 23904,
//         tVOC: 50,
//         dt: 1746135300,
//         eCO2: 721,
//         forwarder: "forwarder_NAS-220P",
//         humidity: 28.9,
//         temperature: 78.9
//      ),
//      AQSample(
//         id: 23905,
//         tVOC: 100,
//         dt: 1746135360,
//         eCO2: 761,
//         forwarder: "forwarder_NAS-220P",
//         humidity: 42.0,
//         temperature: 78.8
//      ),
//      AQSample(
//         id: 23908,
//         tVOC: 0,
//         dt: 1746135540,
//         eCO2: 841,
//         forwarder: "forwarder_NAS-220P",
//         humidity: 42.6,
//         temperature: 78.7
//      ),
//      AQSample(
//         id: 23909,
//         tVOC: 30,
//         dt: 1746135627,
//         eCO2: 1502,
//         forwarder: "forwarder_NAS-220P",
//         humidity: 53.7,
//         temperature: 79.8
//      ),
//      AQSample(
//         id: 23910,
//         tVOC: 35,
//         dt: 1746135687,
//         eCO2: 1522,
//         forwarder: "forwarder_NAS-220P",
//         humidity: 54.1,
//         temperature: 79.9
//      ),
//      AQSample(
//         id: 23911,
//         tVOC: 40,
//         dt: 1746135721,
//         eCO2: 1542,
//         forwarder: "forwarder_NAS-220P",
//         humidity: 54.5,
//         temperature: 80.0
//      ),
//      AQSample(
//         id: 23912,
//         tVOC: 45,
//         dt: 1746135780,
//         eCO2: 1562,
//         forwarder: "forwarder_NAS-220P",
//         humidity: 54.9,
//         temperature: 80.1
//      ),
//      AQSample(
//         id: 23913,
//         tVOC: 55,
//         dt: 1746135841,
//         eCO2: 1205,
//         forwarder: "forwarder_NAS-220P",
//         humidity: 54.1,
//         temperature: 80.0
//      )
//   ]
//   
//   static let mockDataDay2: [AQSample] = [
//      AQSample(
//         id: 34230,
//         tVOC: 208,
//         dt: 1746832260,
//         eCO2: 641,
//         forwarder: "forwarder_NAS-220P",
//         humidity: 46.4,
//         temperature: 74.4
//      ),
//      AQSample(
//         id: 34231,
//         tVOC: 216,
//         dt: 1746832320,
//         eCO2: 642,
//         forwarder: "forwarder_NAS-220P",
//         humidity: 46.3,
//         temperature: 74.5
//      ),
//      AQSample(
//         id: 34232,
//         tVOC: 201,
//         dt: 1746832381,
//         eCO2: 620,
//         forwarder: "forwarder_NAS-220P",
//         humidity: 46.2,
//         temperature: 74.5
//      ),
//      AQSample(
//         id: 34233,
//         tVOC: 145,
//         dt: 1746832440,
//         eCO2: 588,
//         forwarder: "forwarder_NAS-220P",
//         humidity: 45.7,
//         temperature: 74.4
//      ),
//      AQSample(
//         id: 34234,
//         tVOC: 180,
//         dt: 1746832502,
//         eCO2: 627,
//         forwarder: "forwarder_NAS-220P",
//         humidity: 46.2,
//         temperature: 74.5
//      ),
//      AQSample(
//         id: 34235,
//         tVOC: 207,
//         dt: 1746832560,
//         eCO2: 620,
//         forwarder: "forwarder_NAS-220P",
//         humidity: 46.1,
//         temperature: 74.5
//      ),
//      AQSample(
//         id: 34236,
//         tVOC: 323,
//         dt: 1746832621,
//         eCO2: 649,
//         forwarder: "forwarder_NAS-220P",
//         humidity: 46.6,
//         temperature: 74.6
//      ),
//      AQSample(
//         id: 34237,
//         tVOC: 375,
//         dt: 1746832682,
//         eCO2: 666,
//         forwarder: "forwarder_NAS-220P",
//         humidity: 45.9,
//         temperature: 74.7
//      ),
//      AQSample(
//         id: 34238,
//         tVOC: 627,
//         dt: 1746832740,
//         eCO2: 1205,
//         forwarder: "forwarder_NAS-220P",
//         humidity: 46.3,
//         temperature: 74.6
//      ),
//      AQSample(
//         id: 34239,
//         tVOC: 114,
//         dt: 1746832802,
//         eCO2: 469,
//         forwarder: "forwarder_NAS-220P",
//         humidity: 45.3,
//         temperature: 74.6
//      ),
//      AQSample(
//         id: 342340,
//         tVOC: 216,
//         dt: 1746832860,
//         eCO2: 575,
//         forwarder: "forwarder_NAS-220P",
//         humidity: 46.4,
//         temperature: 74.5
//      ),
//      AQSample(
//         id: 34241,
//         tVOC: 122,
//         dt: 1746832920,
//         eCO2: 400,
//         forwarder: "forwarder_NAS-220P",
//         humidity: 44.9,
//         temperature: 74.6
//      ),
//      AQSample(
//         id: 34242,
//         tVOC: 187,
//         dt: 1746832980,
//         eCO2: 544,
//         forwarder: "forwarder_NAS-220P",
//         humidity: 46.4,
//         temperature: 74.5
//      )
//   ]
}
