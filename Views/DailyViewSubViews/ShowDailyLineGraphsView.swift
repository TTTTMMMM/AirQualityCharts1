import SwiftUI
import Charts

struct ShowDailyLineGraphsView: View {
   
   @StateObject var viewModel = DailyViewModel()
   
   @Binding var selectedDate: Date
   @Binding var displayTemperature: Bool
   @Binding var displayHumidity: Bool
   @Binding var displayECO2: Bool
   @Binding var displayTVOC: Bool
   
   @State var isLoading: Bool = true
   
   private var dateFormatter: DateFormatter {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "MMM dd, yyyy"
      return dateFormatter
   }
   
    var body: some View {
          GroupBox {
             Text("Daily Environment Chart for \(self.dateFormatter.string(from: self.selectedDate))")
                .font(.title2)
             if(isLoading) {
                ProgressView()
                   .scaleEffect(2)
             }
             Chart {
                ForEach (viewModel.aqMeasurements)  { measurement in
                   if displayTemperature {
                      PointMark(
                         x: .value("timestamp", measurement.timeString),
                         y: .value("temperature", measurement.temperature)
                      )
                      .symbol(.triangle)
                      .foregroundStyle(.green)
                      LineMark(
                         x: .value("timestamp", measurement.timeString),
                         y: .value("temperature", measurement.temperature),
                         series: .value("temperature", "A")
                      )
                      .foregroundStyle(Color.green)
                   }
                   if displayHumidity {
                      PointMark(
                         x: .value("timestamp", measurement.timeString),
                         y: .value("humidity", measurement.humidity)
                      )
                      .symbol(.circle)
                      .foregroundStyle(.black)
                      LineMark(
                         x: .value("timestamp", measurement.timeString),
                         y: .value("humidity", measurement.humidity),
                         series: .value("humidity", "B")
                      )
                      .foregroundStyle(Color.black)
                   }
                   if displayECO2 {
                      PointMark(
                         x: .value("timestamp", measurement.timeString),
                         y: .value("ECO2", measurement.unBiasedECO2)
                      )
                      .symbol(.cross)
                      .foregroundStyle(.blue)
                      LineMark(
                         x: .value("timestamp", measurement.timeString),
                         y: .value("ECO2", measurement.unBiasedECO2),
                         series: .value("unBiasedECO2", "C")
                      )
                      .foregroundStyle(Color.blue)
                   }
                   if displayTVOC {
                      PointMark(
                         x: .value("timestamp", measurement.timeString),
                         y: .value("TVOC", measurement.tVOC)
                      )
                      .symbol(.diamond)
                      .foregroundStyle(.red)
                      LineMark(
                         x: .value("timestamp", measurement.timeString),
                         y: .value("TVOC", measurement.tVOC),
                         series: .value("tVOC", "D")
                      )
                      .foregroundStyle(Color.red)
                   }
                }
             }
             .transition(.opacity)
             .animation(.linear(duration: 0.6), value: displayTemperature)
             .animation(.linear(duration: 0.6), value: displayHumidity)
             .animation(.linear(duration: 0.6), value: displayECO2)
             .animation(.linear(duration: 0.6), value: displayTVOC)
             .animation(.linear(duration: 2.6), value: viewModel.aqMeasurements)
             .chartScrollableAxes(.horizontal)
             .chartXVisibleDomain(length: 10)
             .chartLegend(position: .top, alignment: .leading, spacing: 8)
//             .chartForegroundStyleScale(
//                ["Temperature": Color.accentColor,
//                 "Humidity": Color.black,
//                 "eCO2": Color.blue,
//                 "tVOC": Color.red
//                ]
//             )
             .chartForegroundStyleScale(
               ["Temperature": Color.accentColor, "eCO2": Color.blue, "TVOC": Color.red]
             )
             .chartYAxis {
                AxisMarks(position: .leading)
             }
          }
          .task {
             do {
                isLoading = true
//                try await viewModel.createSample()
                try await viewModel.getSample()
                try await viewModel.getAQMeasurements(dt: 1746135360)
                isLoading = false
             }
             catch {
                print(error.localizedDescription)
             }
          }
          .padding(12)
       }
}

#Preview {

   @Previewable @State var selectedDate = Date()
   @Previewable @State var displayTemperature = true
   @Previewable @State var displayHumidity = true
   @Previewable @State var displayECO2 = true
   @Previewable @State var displayTVOC = true
   
   ShowDailyLineGraphsView(
      selectedDate: $selectedDate,
      displayTemperature: $displayTemperature,
      displayHumidity: $displayHumidity,
      displayECO2: $displayECO2,
      displayTVOC: $displayTVOC
   )
}
