import SwiftUI
import Charts

struct ShowDailyLineGraphsViewAQ: View {
   
   @StateObject var viewModel = AirQualityViewModel()
   
   @Binding var selectedDate: Date
   @Binding var displayTemperature: Bool
   @Binding var displayHumidity: Bool
   @Binding var displayECO2: Bool
   @Binding var displayTVOC: Bool
   
   @State var isLoading: Bool = true
   
   private var dateFormatter: DateFormatter {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "EEEE dd MMM yyyy"
      return dateFormatter
   }
   
   var body: some View {
      GroupBox {
         Text("CO₂ and TVOC: \(self.dateFormatter.string(from: self.selectedDate))")
            .font(.title2)
         if(isLoading) {
            ProgressView()
               .scaleEffect(2)
         }
         Chart {
            ForEach (viewModel.aqMeasurements)  { measurement in
               if displayTemperature {
                  LineMark(
                     x: .value("timestamp", measurement.timeString),
                     y: .value("temperature", measurement.temperature),
                     series: .value("temperature", "A")
                  )
                  .foregroundStyle(Color.green)
               }
               if displayHumidity {
                  LineMark(
                     x: .value("timestamp", measurement.timeString),
                     y: .value("humidity", measurement.humidity),
                     series: .value("humidity", "B")
                  )
                  .foregroundStyle(Color.yellow)
               }
               if displayECO2 {
                  LineMark(
                     x: .value("timestamp", measurement.timeString),
                     y: .value("ECO2", measurement.unBiasedECO2AndScaled),
                     series: .value("unBiasedECO2", "C")
                  )
                  .foregroundStyle(Color.blue)
               }
               if displayTVOC {
                  LineMark(
                     x: .value("timestamp", measurement.timeString),
                     y: .value("TVOC", measurement.scaledTVOC),
                     series: .value("tVOC", "D")
                  )
                  .foregroundStyle(Color.red)
               }
            }  // ForEach
         }     // Chart
      }        // GroupBox
      .chartYAxis {
          AxisMarks(position: .leading) { value in
              AxisGridLine()
              AxisValueLabel()
          }
      }
      .chartXAxis {
         AxisMarks(  // label every 15 mins = 90 when sampled 6 times per minute
            values: .automatic(desiredCount: 90)
         ) { mark in
            if mark.index % 90 == 0 {
               AxisValueLabel() {
                  if let dateString = mark.as(String.self) {
                     Text(String(dateString.prefix(5)))
                  }
               }
               AxisGridLine()
            }
         }
      }
      .chartLegend(position: .top, alignment: .leading, spacing: 8)
      .chartForegroundStyleScale(
         ["Temperature": Color.accentColor,
          "Humidity": Color.yellow,
          "CO₂": Color.blue,
          "tVOC": Color.red
         ]
      )
      .transition(.opacity)
      .animation(.linear(duration: 0.6), value: displayTemperature)
      .animation(.linear(duration: 0.6), value: displayHumidity)
      .animation(.linear(duration: 0.6), value: displayECO2)
      .animation(.linear(duration: 0.6), value: displayTVOC)
      .animation(.linear(duration: 0.6), value: viewModel.aqMeasurements)
      .chartScrollableAxes(.horizontal)
      .chartXVisibleDomain(length: min(viewModel.numberOfSamplesRetrieved ?? 1800, 1800))  // 1800 = 5 hours
      .padding(12)
      .task {
         do {
            isLoading = true
            try await viewModel.getOneDayOfSamples(date: selectedDate)
            isLoading = false
         }
         catch {
            print(error.localizedDescription)
         }     // catch
      }        // task
   }           // Body
}              // View

#Preview {
   
   @Previewable @State var selectedDate = Date()
   @Previewable @State var displayTemperature = true
   @Previewable @State var displayHumidity = true
   @Previewable @State var displayECO2 = true
   @Previewable @State var displayTVOC = true
   
   ShowDailyLineGraphsViewAQ(
      selectedDate: $selectedDate,
      displayTemperature: $displayTemperature,
      displayHumidity: $displayHumidity,
      displayECO2: $displayECO2,
      displayTVOC: $displayTVOC
   )
}
