import SwiftUI
import Charts

struct ShowHourlyLineGraphsViewMerged: View {
   
   @StateObject var viewModelMerged = MergedSamplesViewModel()
   
   @Binding var selectedDateHour: Date
   @Binding var numberOfHoursDuration: String
   @Binding var displayTemperature: Bool
   @Binding var displayHumidity: Bool
   @Binding var displayECO2: Bool
   @Binding var displayTVOC: Bool
   @Binding var displayPM03um: Bool
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
         Text("Air Quality: \(self.dateFormatter.string(from: self.selectedDateHour))")
            .font(.title2)
         if(isLoading) {
            ProgressView()
               .scaleEffect(2)
         }
//         else {
            ZStack(alignment: .top) {
               Chart {
                  ForEach (viewModelMerged.mergedData)  { measurement in
                     if (!isLoading && displayTemperature) {
                        LineMark(
                           x: .value("timestamp", measurement.timeString),
                           y: .value("temperature", measurement.temperature),
                           series: .value("temperature", "A")
                        )
                        .foregroundStyle(Color.green)
                     }
                     if (!isLoading && displayHumidity) {
                        LineMark(
                           x: .value("timestamp", measurement.timeString),
                           y: .value("humidity", measurement.humidity),
                           series: .value("humidity", "B")
                        )
                        .foregroundStyle(Color.yellow)
                     }
                     if (!isLoading && displayECO2) {
                        LineMark(
                           x: .value("timestamp", measurement.timeString),
                           y: .value("ECO2", measurement.unBiasedECO2AndScaled),
                           series: .value("unBiasedECO2", "C")
                        )
                        .foregroundStyle(Color.blue)
                     }
                     if (!isLoading && displayTVOC) {
                        LineMark(
                           x: .value("timestamp", measurement.timeString),
                           y: .value("TVOC", measurement.scaledTVOC),
                           series: .value("tVOC", "D")
                        )
                        .foregroundStyle(Color.red)
                     }
                     if (!isLoading && displayPM03um) {
                        LineMark(
                           x: .value("timestamp", measurement.timeString),
                           y: .value("pm03um", measurement.pm03um),
                           series: .value("scaledPM03um", "E")
                        )
                        .foregroundStyle(Color.mint)
                     }
                     if (!isLoading && displayPM100s) {
                        LineMark(
                           x: .value("timestamp", measurement.timeString),
                           y: .value("pm100s", measurement.pm100s),
                           series: .value("pm100s", "F")
                        )
                        .foregroundStyle(Color.purple)
                     }
                  } // ForEach
               }    // Chart
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
                   "tVOC": Color.red,
                   "PM 0.3 μm": Color.mint,
                   "PM 10.0s": Color.purple
                  ]
               )
               .transition(.opacity)
               .animation(.linear(duration: 0.6), value: displayTemperature)
               .animation(.linear(duration: 0.6), value: displayHumidity)
               .animation(.linear(duration: 0.6), value: displayECO2)
               .animation(.linear(duration: 0.6), value: displayTVOC)
               .animation(.linear(duration: 0.6), value: displayPM03um)
               .animation(.linear(duration: 0.6), value: displayPM100s)
               .animation(.linear(duration: 0.6), value: viewModelMerged.aqMeasurements)
               .chartScrollableAxes(.horizontal)
               .chartXVisibleDomain(length: viewModelMerged.numberOfSamplesRetrievedAQ ?? lengthOfData)
               .padding(12)
               VStack {        //average and maximums here, with dbl-tap to choose between the two
                  if showingAverages {
                     AverageViewMerged(avgValuesMerged: $viewModelMerged.avgValuesMerged, titleOfPanel: "Averages")
                  } else {
                     MaxViewMerged(maxValuesMerged: $viewModelMerged.maxValuesMerged, titleOfPanel: "Maximums")
                  }
               }
               .onTapGesture(count: 2) { // Detect double-tap
                  withAnimation {       // Optional: Animate the view transition
                     showingAverages.toggle() // Toggle the state to switch views
                  }
               }
               .offset(x: -65, y: 20)
            } // ZStack
//         }    // else
      }       // GroupBox
      .task {
         do {
            isLoading = true
            try await viewModelMerged.getSecifiedHoursWorthOfSamplesPM(
               date: selectedDateHour,
               numberOfHours: Int(numberOfHoursDuration) ?? 1
            )
            try await viewModelMerged.getSecifiedHoursWorthOfSamplesAQ(
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
   @Previewable @State var displayTemperature = true
   @Previewable @State var displayHumidity = true
   @Previewable @State var displayECO2 = true
   @Previewable @State var displayTVOC = true
   @Previewable @State var displayPM03um = true
   @Previewable @State var displayPM100s = true
   
   ShowHourlyLineGraphsViewMerged(
      selectedDateHour: $selectedDate,
      numberOfHoursDuration: $numberOfHoursDuration,
      displayTemperature: $displayTemperature,
      displayHumidity: $displayHumidity,
      displayECO2: $displayECO2,
      displayTVOC: $displayTVOC,
      displayPM03um: $displayPM03um,
      displayPM100s: $displayPM100s
   )
}

