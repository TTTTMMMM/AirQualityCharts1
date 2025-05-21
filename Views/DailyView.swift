//
// https://www.youtube.com/playlist?list=PLwvDm4Vfkdphl8ly0oi0aHx0v2B7UvDK0
//
import SwiftUI
import Charts

struct DailyView: View {

   @StateObject var viewModel = DailyViewModel()
   @State var selectedDate = Date()
   @State var charted = false
   @State var displayTemperature = true
   @State var displayHumidity = true
   @State var displayECO2 = true
   @State var displayTVOC = true
   
   private var dateFormatter: DateFormatter {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "MMM dd, yyyy"
      return dateFormatter
   }
   private var dateFormatter2: DateFormatter {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
      return dateFormatter
   }
   
   var body: some View {
      VStack (alignment: .center) {
         DatePickerSectionView(selectedDate: $selectedDate, charted: $charted)
      }
      Spacer()
         .fullScreenCover(isPresented: $charted) {
            dailyChartSheet()
               .task {
                  do {
                     try await viewModel.createSample()
                     try await viewModel.getSample()
                     try await viewModel.getAQMeasurements(dt: 1746135360)
                  }
                  catch {
                     print(error.localizedDescription)
                  }
               }
         }
         .padding()
         .background(Color.white)
   }
}


#Preview {
   DailyView()
}

extension DailyView {
   
   func showLineGraphs() -> some View {
      GroupBox {
         Text("Daily Environment Chart for \(self.dateFormatter.string(from: self.selectedDate))")
            .font(.title2)
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
//         .chartForegroundStyleScale(
//            ["Temperature": Color.accentColor,
//             "Humidity": Color.black,
//             "eCO2": Color.blue,
//             "tVOC": Color.red
//            ]
//         )
         .chartForegroundStyleScale(["Temperature": Color.accentColor, "eCO2": Color.blue, "TVOC": Color.red])
         .chartYAxis {
            AxisMarks(position: .leading)
         }
      }
      .padding(12)
   }
   
   func dailyChartSheet() -> some View {
      VStack () {
         showLineGraphs()
      }
      .ignoresSafeArea()
      .background(.ultraThinMaterial)
      .overlay(backButtonView(charted: $charted), alignment: .topLeading)
      .overlay(CauseAndGraphPickerView(displayTemperature: $displayTemperature, displayHumidity: $displayHumidity, displayECO2: $displayECO2, displayTVOC: $displayTVOC), alignment: .topTrailing)
   }
}
