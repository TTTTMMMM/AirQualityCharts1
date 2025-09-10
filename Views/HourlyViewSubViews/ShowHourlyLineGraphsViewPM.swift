import SwiftUI
import Charts

struct ShowHourlyLineGraphsViewPM: View {
   
   @StateObject var viewModel = ParticleCountsViewModel()
   
   @Binding var selectedDateHour: Date
   @Binding var numberOfHoursDuration: String
   @Binding var displayPM03um: Bool
   @Binding var displayPM05um: Bool
   @Binding var displayPM1um: Bool
   @Binding var displayPM25um: Bool
   @Binding var displayPM5um: Bool
   @Binding var displayPM10um: Bool
   
   @State var isLoading: Bool = true
   
   private var dateFormatter: DateFormatter {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "EEEE dd MMM yyyy HH:00"
      return dateFormatter
   }
   
   private var lengthOfData: Int {
      let numDuration = Int(numberOfHoursDuration) ?? 2
      return numDuration*60*6
   }
   
   var body: some View {
      GroupBox {
         Text("Particulate Matter: \(self.dateFormatter.string(from: self.selectedDateHour))")
            .font(.title2)
         if(isLoading) {
            ProgressView()
               .scaleEffect(2)
         }
         Chart {
            ForEach (viewModel.pmMeasurements) { measurement in
               if displayPM03um {
                  LineMark(
                     x: .value("timestamp", measurement.timeString),
                     y: .value("pm03um", measurement.pm03um),
                     series: .value("scaledPM03um", "A")
                  )
                  .foregroundStyle(Color.green)
               }
               if displayPM05um {
                  LineMark(
                     x: .value("timestamp", measurement.timeString),
                     y: .value("pm05um", measurement.pm05um),
                     series: .value("scaledPM05um", "B")
                  )
                  .foregroundStyle(Color.yellow)
               }
               if displayPM1um {
                  LineMark(
                     x: .value("timestamp", measurement.timeString),
                     y: .value("pm1um", measurement.pm1um),
                     series: .value("scaledPM1um", "C")
                  )
                  .foregroundStyle(Color.blue)
               }
               if displayPM25um {
                  LineMark(
                     x: .value("timestamp", measurement.timeString),
                     y: .value("pm25um", measurement.pm25um),
                     series: .value("pm25um", "D")
                  )
                  .foregroundStyle(Color.red)
               }
               if displayPM5um {
                  LineMark(
                     x: .value("timestamp", measurement.timeString),
                     y: .value("pm5um", measurement.pm5um),
                     series: .value("pm5um", "E")
                  )
                  .foregroundStyle(Color.purple)
               }
               if displayPM10um {
                  LineMark(
                     x: .value("timestamp", measurement.timeString),
                     y: .value("pm10um", measurement.pm10um),
                     series: .value("pm10um", "F")
                  )
                  .foregroundStyle(Color.mint)
               }
            }  // ForEach
         }    // Chart
      }       // GroupBox
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
         ["0.3µm": Color.accentColor,
          "0.5µm": Color.yellow,
          "1.0µm": Color.blue,
          "2.5µm": Color.red,
          "5.0µm": Color.purple,
          "10.0µm": Color.mint
         ]
      )
      .transition(.opacity)
      .animation(.linear(duration: 0.6), value: displayPM03um)
      .animation(.linear(duration: 0.6), value: displayPM05um)
      .animation(.linear(duration: 0.6), value: displayPM1um)
      .animation(.linear(duration: 0.6), value: displayPM25um)
      .animation(.linear(duration: 0.6), value: displayPM5um)
      .animation(.linear(duration: 0.6), value: displayPM10um)
      .animation(.linear(duration: 0.6), value: viewModel.pmMeasurements)
      .chartScrollableAxes(.horizontal)
      .chartXVisibleDomain(length: viewModel.numberOfSamplesRetrieved ?? lengthOfData)
      .padding(12)
      .task {
         do {
            isLoading = true
            try await viewModel.getSecifiedHoursWorthOfSamples(
               date: selectedDateHour,
               numberOfHours: Int(numberOfHoursDuration) ?? 1
            )
            isLoading = false
         }
         catch {
            print(error.localizedDescription)
         }
      }
   }
}

#Preview {
   
   @Previewable @State var selectedDate = Date()
   @Previewable @State var numberOfHoursDuration = "1"
   @Previewable @State var displayPM03um = true
   @Previewable @State var displayPM05um = true
   @Previewable @State var displayPM1um  = true
   @Previewable @State var displayPM25um = true
   @Previewable @State var displayPM5um  = true
   @Previewable @State var displayPM10um = true
   
   ShowHourlyLineGraphsViewPM(
      selectedDateHour: $selectedDate,
      numberOfHoursDuration: $numberOfHoursDuration,
      displayPM03um: $displayPM03um,
      displayPM05um: $displayPM05um,
      displayPM1um:  $displayPM1um,
      displayPM25um: $displayPM25um,
      displayPM5um: $displayPM5um,
      displayPM10um: $displayPM10um
   )
}
