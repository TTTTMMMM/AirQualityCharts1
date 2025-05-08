import Foundation

class AQViewModel: ObservableObject {
   
   @Published var aqMeasurements: [AQMeasurement] = []
//   @Published var startingIndex: Int?
   var graphDescriptors: [aqGraphDesc] = []
   let temperatureGraphDescriptor: aqGraphDesc = aqGraphDesc(graphType: .temperature, yValue: "temperature", seriesValue: "A", graphColor: .green, symbolName: "triangle")
   let humidityGraphDescriptor:    aqGraphDesc = aqGraphDesc(graphType: .humidity, yValue: "humidity", seriesValue: "B", graphColor: .black, symbolName: "cross")
   let eCO2GraphDescriptor:        aqGraphDesc = aqGraphDesc(graphType: .eCO2, yValue: "ECO2", seriesValue: "C", graphColor: .blue, symbolName: "circle")
   let tVOCGraphDescriptor:        aqGraphDesc = aqGraphDesc(graphType: .tVOC, yValue: "tVOC", seriesValue: "D", graphColor: .red, symbolName: "diamond")
   
   init() {
      print("AQViewModel.init()")
      self.graphDescriptors.append(temperatureGraphDescriptor)
      self.graphDescriptors.append(humidityGraphDescriptor)
      self.graphDescriptors.append(eCO2GraphDescriptor)
      self.graphDescriptors.append(tVOCGraphDescriptor)

      let aqMeasurements = AQDataService.measurements
      self.aqMeasurements = aqMeasurements
   }
   
   func getAQMeasurements(dt: Int) -> Void {
      print("AQViewModel.getAQMeasurements()")
//      self.aqMeasurements.removeFirst()
   }
      
   
}
