import SwiftUI
import Charts

func getRoundedDateTwoHoursAgo1() -> Date {
    let now = Date()
    let twoHoursAgo = now.addingTimeInterval(-2 * 60 * 60) // Subtract 2 hours (in seconds)

    let calendar = Calendar.current
    let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: twoHoursAgo)

    guard let hour = components.hour, let minute = components.minute else {
        return twoHoursAgo // Fallback if components are not available
    }

    // Calculate total minutes from the beginning of the day for rounding
    let totalMinutes = hour * 60 + minute

    // Determine the nearest 15-minute interval
    let roundedMinutes = Int(round(Double(totalMinutes) / 15.0)) * 15

    // Reconstruct the date with the rounded minutes
    var newComponents = DateComponents()
    newComponents.year = components.year
    newComponents.month = components.month
    newComponents.day = components.day
    newComponents.hour = roundedMinutes / 60
    newComponents.minute = roundedMinutes % 60
    newComponents.second = 0 // Set seconds to 0 for consistent rounding

    return calendar.date(from: newComponents) ?? twoHoursAgo // Fallback if date cannot be created
}

struct ShowRealTimeLineGraphViewMerged: View {
   
   @StateObject var viewModelMerged = MergedSamplesViewModel()
   @Binding var displayTemperature: Bool
   @Binding var displayHumidity: Bool
   @Binding var displayECO2: Bool
   @Binding var displayTVOC: Bool
   @Binding var displayPM03um: Bool
   @Binding var displayPM100s: Bool
   
   @State private var didAppear: Bool = false  // only call on the 1rst time the view is created
   @State private var showingAverages = true
   @State var isLoading: Bool = true
   
   var selectedDateHour: Date = Date()
   var startTime = getRoundedDateTwoHoursAgo1()
   
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
         Text("Realtime CO₂, TVOC, & PM for \(self.dateFormatter.string(from: self.selectedDateHour)) starting at \(self.dateFormatter2.string(from: self.startTime))")
            .font(.title2)
         if(isLoading) {
            ProgressView()
               .scaleEffect(2)
         }
         ZStack (alignment: .top) {
            Chart {
               ForEach (viewModelMerged.mergedData)  { measurement in
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
                  if displayPM03um {
                     LineMark(
                        x: .value("timestamp", measurement.timeString),
                        y: .value("pm03um", measurement.pm03um),
                        series: .value("scaledPM03um", "E")
                     )
                     .foregroundStyle(Color.mint)
                  }
                  if displayPM100s {
                     LineMark(
                        x: .value("timestamp", measurement.timeString),
                        y: .value("pm100s", measurement.pm100s),
                        series: .value("pm100s", "F")
                     )
                     .foregroundStyle(Color.purple)
                  }
               }
            }
            .transition(.opacity)
            .animation(.linear(duration: 0.6), value: displayTemperature)
            .animation(.linear(duration: 0.6), value: displayHumidity)
            .animation(.linear(duration: 0.6), value: displayECO2)
            .animation(.linear(duration: 0.6), value: displayTVOC)
            .animation(.linear(duration: 0.6), value: displayPM03um)
            .animation(.linear(duration: 0.6), value: displayPM100s)
            .animation(.linear(duration: 0.6), value: viewModelMerged.mergedData)
            .chartScrollableAxes(.horizontal)
            .chartXVisibleDomain(length: 1080)   // 1080 = 3 hours worth of samples
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
            .chartYAxis {
               AxisMarks(position: .leading)
            }
            HStack {
               Spacer()
               causeAndGraphPickerView2()
            }
            VStack {        //average and maximums here, with dbl-tap to choose between the two
               if showingAverages {
                  AverageViewMerged(avgValuesMerged: $viewModelMerged.avgValuesMergedLastHour, titleOfPanel: "Last Hour Averages")
               } else {
                  MaxViewMerged(maxValuesMerged: $viewModelMerged.maxValuesMergedLastHour, titleOfPanel: "Last Hour Maximums")
               }
            }
            .onTapGesture(count: 2) { // Detect double-tap
                withAnimation {       // Optional: Animate the view transition
                   showingAverages.toggle() // Toggle the state to switch views
                }
            }
            .offset(x: -150, y: 10)
         }    // ZStack
      }       // GroupBox
      .onAppear {
         if(!didAppear) {
            didAppear = true
            isLoading = true
            viewModelMerged.addListenerForAQSamples()
            viewModelMerged.addListenerForParticleCountsSizes()
            isLoading = false
         }
      }
      .onDisappear {
         viewModelMerged.cancelCombineSubscriptionsAQ()
         viewModelMerged.cancelCombineSubscriptionsPM()
      }
   }
}

#Preview {

   @Previewable @State var displayTemperature = true
   @Previewable @State var displayHumidity = true
   @Previewable @State var displayECO2 = true
   @Previewable @State var displayTVOC = true
   @Previewable @State var displayPM03um = true
   @Previewable @State var displayPM100s = true
   
   ShowRealTimeLineGraphViewMerged(
      displayTemperature: $displayTemperature,
      displayHumidity: $displayHumidity,
      displayECO2: $displayECO2,
      displayTVOC: $displayTVOC,
      displayPM03um: $displayPM03um,
      displayPM100s: $displayPM100s
   )
}

extension ShowRealTimeLineGraphViewMerged {
   func LastSampleView() -> some View {
      var dateFormatter2: DateFormatter {
         let dateFormatter = DateFormatter()
         dateFormatter.dateFormat = "YYYY-MMM-dd HH:mm:ss"
         return dateFormatter
      }
      
      return
         VStack (alignment: .leading) {
            if let lsAQ = viewModelMerged.lastSampleAQ {
               if let lsPM = viewModelMerged.lastSamplePM {
                  Text("Last Sample")
                     .font(.subheadline)
                     .foregroundStyle(.white)
                     .frame(maxWidth: .infinity, alignment: .center)
                  Text(verbatim: "ID: \(lsAQ.id)")
                  Text(verbatim: "Temperature: \(lsAQ.temperature)°F")
                  Text(verbatim: "Humidity: \(lsAQ.humidity)%")
                  Text(verbatim: "CO₂: \(lsAQ.eCO2) -> \(lsAQ.unBiasedECO2AndScaled)")
                  Text(verbatim: "TVOC: \(lsAQ.tVOC) -> \(lsAQ.scaledTVOC)")
                  Text(verbatim: "ID_PM: \(lsPM.id)")
                  Text(verbatim: "# > 0.3µm: \(lsPM.pm03um)")
                  Text(verbatim: "PM10: \(lsPM.pm100s)")
                  Text("\(dateFormatter2.string(from: lsAQ.dt))")
               }
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
         .animation(.linear(duration: 0.6), value: viewModelMerged.lastSampleAQ)
         .animation(.linear(duration: 0.6), value: viewModelMerged.lastSamplePM)
      }
}

extension ShowRealTimeLineGraphViewMerged {
   
   func causeAndGraphPickerView2() -> some View {
      
      return
         HStack (alignment: .top) {
            LastSampleView()
               .padding(.top, 14)
            VStack(alignment: .leading, spacing: 10) {
               if let dfl = viewModelMerged.dailyFreebiesLeft {
                  Text("Freebies Left: \(dfl)")
                     .font(.caption2)
                     .padding(4)
                     .transition(.opacity)
                     .animation(.linear(duration: 0.6), value: viewModelMerged.dailyFreebiesLeft)
               }
               GraphPickerViewMerged(
                  displayTemperature: $displayTemperature,
                  displayHumidity: $displayHumidity,
                  displayECO2: $displayECO2,
                  displayTVOC: $displayTVOC,
                  displayPM03um: $displayPM03um,
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

