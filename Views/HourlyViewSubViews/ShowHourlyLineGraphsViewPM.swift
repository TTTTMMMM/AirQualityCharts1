import SwiftUI
import Charts

struct ShowHourlyLineGraphsViewPM: View {
   
   @StateObject var viewModel = ParticleCountsViewModel()
   
   @Binding var selectedDateHour: Date
   @Binding var numberOfHoursDuration: String
   @Binding var displayPM03um: Bool
   @Binding var displayPM10s:  Bool
   @Binding var displayPM25s:  Bool
   @Binding var displayPM100s: Bool
   
   @State private var showingAverages = true
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
         ZStack {
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
                  if displayPM10s {
                     LineMark(
                        x: .value("timestamp", measurement.timeString),
                        y: .value("pm10s", measurement.pm10s),
                        series: .value("scaledPM05um", "B")
                     )
                     .foregroundStyle(Color.yellow)
                  }
                  if displayPM25s {
                     LineMark(
                        x: .value("timestamp", measurement.timeString),
                        y: .value("pm25s", measurement.pm25s),
                        series: .value("scaledPM1um", "C")
                     )
                     .foregroundStyle(Color.blue)
                  }
                  if displayPM100s {
                     LineMark(
                        x: .value("timestamp", measurement.timeString),
                        y: .value("pm100s", measurement.pm100s),
                        series: .value("pm25um", "D")
                     )
                     .foregroundStyle(Color.red)
                  }
               }  // ForEach
            } // Chart
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
                "PM1.0": Color.yellow,
                "PM2.5": Color.blue,
                "PM10": Color.red
               ]
            )
            .transition(.opacity)
            .animation(.linear(duration: 0.6), value: displayPM03um)
            .animation(.linear(duration: 0.6), value: displayPM10s)
            .animation(.linear(duration: 0.6), value: displayPM25s)
            .animation(.linear(duration: 0.6), value: displayPM100s)
            .animation(.linear(duration: 0.6), value: viewModel.pmMeasurements)
            .chartScrollableAxes(.horizontal)
            .chartXVisibleDomain(length: viewModel.numberOfSamplesRetrieved ?? lengthOfData)
            .padding(12)
            VStack {        //average and maximums here, with dbl-tap to choose between the two
               if showingAverages {
                  AverageViewPM(avgValuesPM: $viewModel.avgValues)
               } else {
                  MaxViewPM(maxValuesPM: $viewModel.maxValues)
               }
            }
            .onTapGesture(count: 2) { // Detect double-tap
               withAnimation {       // Optional: Animate the view transition
                  showingAverages.toggle() // Toggle the state to switch views
               }
            }
            .offset(x: 85, y: -260)
         }  // ZStack
      }     // GroupBox
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
   @Previewable @State var displayPM10s = true
   @Previewable @State var displayPM25s  = true
   @Previewable @State var displayPM100s = true
   
   ShowHourlyLineGraphsViewPM(
      selectedDateHour: $selectedDate,
      numberOfHoursDuration: $numberOfHoursDuration,
      displayPM03um: $displayPM03um,
      displayPM10s: $displayPM10s,
      displayPM25s:  $displayPM25s,
      displayPM100s: $displayPM100s
   )
}
