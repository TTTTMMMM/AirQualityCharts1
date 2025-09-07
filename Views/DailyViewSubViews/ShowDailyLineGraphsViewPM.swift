import SwiftUI
import Charts

struct ShowDailyLineGraphsViewPM: View {
   
   @StateObject var viewModel = ParticleCountsViewModel()
   
   @Binding var selectedDate: Date
   @Binding var displayPM03um: Bool
   @Binding var displayPM05um: Bool
   @Binding var displayPM1um: Bool
   @Binding var displayPM25um: Bool
   
   @State var isLoading: Bool = true
   
   private var dateFormatter: DateFormatter {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "EEEE MMM dd, yyyy"
      return dateFormatter
   }
   
   var body: some View {
      GroupBox {
         Text("Particulate Matter: \(self.dateFormatter.string(from: self.selectedDate))")
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
                     y: .value("temperature", measurement.scaledPM03um),
                     series: .value("scaledPM03um", "A")
                  )
                  .foregroundStyle(Color.green)
               }
               if displayPM05um {
                  LineMark(
                     x: .value("timestamp", measurement.timeString),
                     y: .value("humidity", measurement.scaledPM05um),
                     series: .value("scaledPM05um", "B")
                  )
                  .foregroundStyle(Color.yellow)
               }
               if displayPM1um {
                  LineMark(
                     x: .value("timestamp", measurement.timeString),
                     y: .value("ECO2", measurement.scaledPM1um),
                     series: .value("scaledPM1um", "C")
                  )
                  .foregroundStyle(Color.blue)
               }
               if displayPM25um {
                  LineMark(
                     x: .value("timestamp", measurement.timeString),
                     y: .value("TVOC", measurement.pm25um),
                     series: .value("pm25um", "D")
                  )
                  .foregroundStyle(Color.red)
               }
            }
         }
         .transition(.opacity)
         .animation(.linear(duration: 0.6), value: displayPM03um)
         .animation(.linear(duration: 0.6), value: displayPM05um)
         .animation(.linear(duration: 0.6), value: displayPM1um)
         .animation(.linear(duration: 0.6), value: displayPM25um)
         .animation(.linear(duration: 0.6), value: viewModel.pmMeasurements)
         .chartScrollableAxes(.horizontal)
         .chartXVisibleDomain(length: 800)
         .chartLegend(position: .top, alignment: .leading, spacing: 8)
         .chartForegroundStyleScale(
            [".3um": Color.accentColor,
             ".5um": Color.yellow,
             "1.0um": Color.blue,
             "2.5um": Color.red
            ]
         )
         .chartXAxis {
            AxisMarks(
               // label once per 1/2 hour
               values: .automatic(desiredCount: 30)
            ) { mark in
               if mark.index % 30 == 0 {
                  AxisValueLabel()
               }
            }
         }
         .chartYAxis {
            AxisMarks(position: .leading)
         }
      }
      .task {
         do {
            isLoading = true
            try await viewModel.getOneDayOfSamples(date: selectedDate)
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
   
   @Previewable @State var selectedDate  = Date()
   @Previewable @State var displayPM03um = true
   @Previewable @State var displayPM05um = true
   @Previewable @State var displayPM1um  = true
   @Previewable @State var displayPM25um = true
   
   ShowDailyLineGraphsViewPM(
      selectedDate:  $selectedDate,
      displayPM03um: $displayPM03um,
      displayPM05um: $displayPM05um,
      displayPM1um:  $displayPM1um,
      displayPM25um: $displayPM25um
   )
}
