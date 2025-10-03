import SwiftUI
import Charts

struct ShowAverageLineGraphsView: View {
   
   @StateObject var viewModel = XBarViewModel()
   
   @Binding var selectedDate: Date
   @Binding var displayAvgTemperature: Bool
   @Binding var displayAvgHumidity: Bool
   @Binding var displayAvgECO2: Bool
   @Binding var displayAvgTVOC: Bool
   
   @State private var showingAverages = true
   @State var isLoading: Bool = true
   
   private var dateFormatter: DateFormatter {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "dd MMM yyyy"
      return dateFormatter
   }
   
   var body: some View {
      GroupBox {
         Text("Daily Averages: \(self.dateFormatter.string(from: self.selectedDate))")
            .font(.title2)
         if(isLoading) {
            ProgressView()
               .scaleEffect(2)
         }
         ZStack {
            Chart {
               ForEach (viewModel.aqDailyXBar)  { computation in
                  if displayAvgTemperature {
                     LineMark(
                        x: .value("timestamp", computation.dateString2),
                        y: .value("temperature", computation.temperature),
                        series: .value("temperature", "A")
                     )
                     .foregroundStyle(Color.green)
                  }
                  if displayAvgHumidity {
                     LineMark(
                        x: .value("timestamp", computation.dateString2),
                        y: .value("humidity", computation.humidity),
                        series: .value("humidity", "B")
                     )
                     .foregroundStyle(Color.yellow)
                  }
                  if displayAvgECO2 {
                     LineMark(
                        x: .value("timestamp", computation.dateString2),
                        y: .value("ECO2", computation.eCO2),
                        series: .value("unBiasedECO2", "C")
                     )
                     .foregroundStyle(Color.blue)
                  }
                  if displayAvgTVOC {
                     LineMark(
                        x: .value("timestamp", computation.dateString2),
                        y: .value("TVOC", computation.tVOC),
                        series: .value("tVOC", "D")
                     )
                     .foregroundStyle(Color.red)
                  }
               }  // ForEach
            }     // Chart
            //      }        // GroupBox
            .chartYAxis {
               AxisMarks(position: .leading) { value in
                  AxisGridLine()
                  AxisValueLabel()
               }
            }
            .chartXAxis {
               AxisMarks(  // label every 1 weeks
                  values: .automatic(desiredCount: 7)
               ) { mark in
                  if mark.index % 7 == 0 {
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
            .animation(.linear(duration: 0.6), value: displayAvgTemperature)
            .animation(.linear(duration: 0.6), value: displayAvgHumidity)
            .animation(.linear(duration: 0.6), value: displayAvgECO2)
            .animation(.linear(duration: 0.6), value: displayAvgTVOC)
            .animation(.linear(duration: 0.6), value: viewModel.aqDailyXBar)
            .chartScrollableAxes(.horizontal)
            .chartXVisibleDomain(length: min(viewModel.numberOfDaysRetrieved ?? 1825, 1825)) // 1825 = 365 days/yr * 5 yrs
            .padding(12)
         }     // ZStack
      }        // GroupBox
      .task {
         do {
            print("In task to fetch XBar data...")
            isLoading = true
            try await viewModel.getXBar(startingFrom: selectedDate, endingAt: Date())
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
