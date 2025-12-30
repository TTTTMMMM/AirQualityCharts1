import SwiftUI
import Charts

struct ShowAverageLineGraphsView: View {
   
   @StateObject var viewModel = XBarViewModel()
   
   @Binding var selectedDate: Date
   @Binding var endDate: Date
   @Binding var displayAvgTemperature: Bool
   @Binding var displayAvgHumidity: Bool
   @Binding var displayAvgECO2: Bool
   @Binding var displayAvgTVOC: Bool
   @Binding var displayAvgPm03um: Bool
   @Binding var displayAvgPm100s: Bool
   
   @State private var showingAverages = true
   @State var isLoading: Bool = true
   
   private var dateFormatter: DateFormatter {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "dd MMM yyyy"
      return dateFormatter
   }
   
   private var dayBeforeEndDate: Date {
      if let db4 = Calendar.current.date(byAdding: .day, value: -1, to: self.endDate) {
         return db4
      } else {
         return self.endDate
      }
   }
   
   var body: some View {
      GroupBox {
         Text("Daily Averages: \(self.dateFormatter.string(from: self.selectedDate)) - \(self.dateFormatter.string(from: self.dayBeforeEndDate))")
            .font(.title2)
         if(isLoading) {
            ProgressView()
               .scaleEffect(2)
         }
         ZStack {
            Chart {
               ForEach (viewModel.combinedDailyXBar)  { computation in
                  
                  if displayAvgTemperature {
                     LineMark(
                        x: .value("timestamp", computation.id),
                        y: .value("temperature", computation.temperature),
                        series: .value("temperature", "A")
                     )
                     .foregroundStyle(Color.green)
                  }
                  if displayAvgHumidity {
                     LineMark(
                        x: .value("timestamp", computation.id),
                        y: .value("humidity", computation.humidity),
                        series: .value("humidity", "B")
                     )
                     .foregroundStyle(Color.yellow)
                  }
                  if displayAvgECO2 {
                     LineMark(
                        x: .value("timestamp", computation.id),
                        y: .value("ECO2", computation.eCO2),
                        series: .value("unBiasedECO2", "C")
                     )
                     .foregroundStyle(Color.blue)
                  }
                  if displayAvgTVOC {
                     LineMark(
                        x: .value("timestamp", computation.id),
                        y: .value("TVOC", computation.tVOC),
                        series: .value("tVOC", "D")
                     )
                     .foregroundStyle(Color.red)
                  }
                  if displayAvgPm03um {
                     LineMark(
                        x: .value("timestamp", computation.id),
                        y: .value("PM03um", computation.pm03um),
                        series: .value("PM 0.3um", "E")
                     )
                     .foregroundStyle(Color.mint)
                  }
                  if displayAvgPm100s {
                     LineMark(
                        x: .value("timestamp", computation.id),
                        y: .value("PM100s", computation.pm100s),
                        series: .value("PM100s", "F")
                     )
                     .foregroundStyle(Color.purple)
                  }
               }  // ForEach
            }     // Chart
            .chartYAxis {
               AxisMarks(position: .leading) { value in
                  AxisGridLine()
                  AxisValueLabel()
               }
            }
            .chartXAxis {
               AxisMarks(  // label every 1 week
                  values: .automatic(desiredCount: 7)
               ) { mark in
                  if mark.index % 7 == 0 {
                     AxisValueLabel() {
                        if let dateString = mark.as(String.self) {
                           Text(String(dateString.suffix(8).replacingOccurrences(of: "-", with: "")))
                        }
                     }
                     AxisGridLine()
                  }
               }
            }
            .chartLegend(position: .top, alignment: .leading, spacing: 8)
            .chartForegroundStyleScale(
               [
                  "temperature": Color.green,
                  "humidity": Color.yellow,
                  "CO₂": Color.blue,
                  "tVOC": Color.red,
                  "PM 0.3 μm": Color.mint,
                  "PM 10.0s": Color.purple
               ]
            )
            .transition(.opacity)
            .animation(.linear(duration: 0.6), value: displayAvgTemperature)
            .animation(.linear(duration: 0.6), value: displayAvgHumidity)
            .animation(.linear(duration: 0.6), value: displayAvgECO2)
            .animation(.linear(duration: 0.6), value: displayAvgTVOC)
            .animation(.linear(duration: 0.6), value: displayAvgPm03um)
            .animation(.linear(duration: 0.6), value: displayAvgPm100s)
            .animation(.linear(duration: 0.6), value: viewModel.combinedDailyXBar)
            .chartScrollableAxes(.horizontal)
            .chartXVisibleDomain(length: min(viewModel.numberOfDaysRetrieved ?? 140, 140)) // 140 = 20 weeks
            .padding(12)
         }     // ZStack
      }        // GroupBox
      .task {
         do {
            isLoading = true
            let startOfDay_Start = Calendar.current.startOfDay(for: selectedDate)
            let startOfDay_End = Calendar.current.startOfDay(for: Date())
            try await viewModel.getXBar(
               startingFrom: startOfDay_Start,
               endingAt: startOfDay_End
            )
            isLoading = false
         }
         catch {
            print(error.localizedDescription)
         }     // catch
      }        // task
   }           // Body
}              // View

#Preview {
   @Previewable @State var endDate = Date()
   @Previewable @State var fourteenDaysAgo = Calendar.current.date(byAdding: .day, value: -14, to: Date())!
   @Previewable @State var displayTemperature = true
   @Previewable @State var displayHumidity = true
   @Previewable @State var displayECO2 = true
   @Previewable @State var displayTVOC = true
   @Previewable @State var displayPm03um = true
   @Previewable @State var displayPm100s = true
   
   ShowAverageLineGraphsView(
      selectedDate: $fourteenDaysAgo,
      endDate: $endDate,
      displayAvgTemperature: $displayTemperature,
      displayAvgHumidity: $displayHumidity,
      displayAvgECO2: $displayECO2,
      displayAvgTVOC: $displayTVOC,
      displayAvgPm03um: $displayPm03um,
      displayAvgPm100s: $displayPm100s
   )
}
