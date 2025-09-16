import SwiftUI
import Charts

struct ShowRealTimeLineGraphViewPM: View {
   
   @StateObject var viewModel = ParticleCountsViewModel()
   @Binding var displayPM03um: Bool
   @Binding var displayPM10s: Bool
   @Binding var displayPM25s:  Bool
   @Binding var displayPM100s: Bool
   
   @State private var didAppear: Bool = false  // only call on the 1rst time the view is created
   @State private var showingAverages = true
   @State var isLoading: Bool = true

   var selectedDateHour: Date = Date()
   var startTime = getRoundedDateTwoHoursAgo()
   
   private var dateFormatter: DateFormatter {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "EEEE dd MMM yyyy"
      return dateFormatter
   }
   
   private var dateFormatter2: DateFormatter {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "HH:mm"
      return dateFormatter
   }
   
   var body: some View {
      GroupBox {
         Text("Realtime Particulate Matter for \(self.dateFormatter.string(from: self.selectedDateHour)) starting at \(self.dateFormatter2.string(from: self.startTime))")
            .font(.title2)
         ZStack (alignment: .top) {
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
                        series: .value("pm10s", "B")
                     )
                     .foregroundStyle(Color.yellow)
                  }
                  if displayPM25s {
                     LineMark(
                        x: .value("timestamp", measurement.timeString),
                        y: .value("pm25s", measurement.pm25s),
                        series: .value("pm25s", "C")
                     )
                     .foregroundStyle(Color.blue)
                  }
                  if displayPM100s {
                     LineMark(
                        x: .value("timestamp", measurement.timeString),
                        y: .value("pm100s", measurement.pm100s),
                        series: .value("pm100s", "D")
                     )
                     .foregroundStyle(Color.red)
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
            .transition(.opacity)
            .animation(.linear(duration: 0.6), value: displayPM03um)
            .animation(.linear(duration: 0.6), value: displayPM10s)
            .animation(.linear(duration: 0.6), value: displayPM25s)
            .animation(.linear(duration: 0.6), value: displayPM100s)
            .animation(.linear(duration: 0.6), value: viewModel.pmMeasurements)
            .chartScrollableAxes(.horizontal)
            .chartXVisibleDomain(length: 900) // 900 is 2.5 hours
            .chartLegend(position: .top, alignment: .leading, spacing: 8)
            .chartForegroundStyleScale(
               ["0.3µm": Color.accentColor,
                "PM1.0": Color.yellow,
                "PM2.5": Color.blue,
                "PM10": Color.red
               ]
            )
            .padding(12)
            HStack {
               Spacer()
               causeAndGraphPickerView3()
            }  // HStack
            VStack {        //average and maximums here, with dbl-tap to choose between the two
               if showingAverages {
                  AverageViewPM(avgValuesPM: $viewModel.avgValuesLastHour)
               } else {
                  MaxViewPM(maxValuesPM: $viewModel.maxValuesLastHour)
               }
            }
            .onTapGesture(count: 2) { // Detect double-tap
                withAnimation {       // Optional: Animate the view transition
                   showingAverages.toggle() // Toggle the state to switch views
                }
            }
            .offset(x: -65, y: 20)
         }       // ZStack
      }          // GroupBox
      .onAppear {
         if(!didAppear) {
            didAppear = true
            isLoading = true
            viewModel.addListenerForParticleCountsSizes()
            isLoading = false
         }
      }
      .onDisappear {
         viewModel.cancelCombineSubscriptions()
      }
   }
}

#Preview {

   @Previewable @State var displayPM03um = true
   @Previewable @State var displayPM10s = true
   @Previewable @State var displayPM25s  = true
   @Previewable @State var displayPM100s = true

   ShowRealTimeLineGraphViewPM(
      displayPM03um: $displayPM03um,
      displayPM10s: $displayPM10s,
      displayPM25s:  $displayPM25s,
      displayPM100s: $displayPM100s
   )
}

extension ShowRealTimeLineGraphViewPM {
   func LastSampleView() -> some View {
      var dateFormatter2: DateFormatter {
         let dateFormatter = DateFormatter()
         dateFormatter.dateFormat = "YYYY-MMM-dd HH:mm:ss"
         return dateFormatter
      }
      
      return
         VStack (alignment: .leading) {
            if let ls = viewModel.lastSample {
               Text("Last Sample")
                  .font(.subheadline)
                  .foregroundStyle(.white)
                  .frame(maxWidth: .infinity, alignment: .center)
               Text(verbatim: "ID: \(ls.id)")
               Text(verbatim: "# > 0.3µm: \(ls.pm03um)")
               Text(verbatim: "PM1.0: \(ls.pm10s)")
               Text(verbatim: "PM2.5: \(ls.pm25s)")
               Text(verbatim: "PM10: \(ls.pm100s)")
               Text("\(dateFormatter2.string(from: ls.dt))")
            }
         }
         .font(.callout)
         .foregroundStyle(.white)
         .padding(6)
         .background(Color.gray.opacity(0.1))
         .clipShape(RoundedRectangle(cornerRadius: 10))
         .overlay(
            RoundedRectangle(cornerRadius: 6)
               .stroke(.black, lineWidth: 1)
         )
         .frame(width: 156)
         .transition(.opacity)
         .animation(.linear(duration: 0.6), value: viewModel.lastSample)
      }
}

extension ShowRealTimeLineGraphViewPM {
   
   func causeAndGraphPickerView3() -> some View {
      
      return
         HStack (alignment: .top) {
            LastSampleView()
               .padding(.top, 14)
            VStack(alignment: .leading, spacing: 10) {
               if let dfl = viewModel.dailyFreebiesLeft {
                  Text("Freebies Left: \(dfl)")
                     .font(.caption2)
                     .padding(4)
                     .transition(.opacity)
                     .animation(.linear(duration: 0.6), value: viewModel.dailyFreebiesLeft)
               }
               GraphPickerViewPM(
                  displayPM03um: $displayPM03um,
                  displayPM10s: $displayPM10s,
                  displayPM25s: $displayPM25s,
                  displayPM100s: $displayPM100s
               )
            }
            .padding(3)
            .background(Color.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
               RoundedRectangle(cornerRadius: 6)
                  .stroke(.black, lineWidth: 1)
            )
            .padding(.top, 14)
         }
   }
}

