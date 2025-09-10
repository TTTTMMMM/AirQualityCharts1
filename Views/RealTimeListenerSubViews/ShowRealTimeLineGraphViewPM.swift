import SwiftUI
import Charts

struct ShowRealTimeLineGraphViewPM: View {
   
   @StateObject var viewModel = ParticleCountsViewModel()
   @Binding var displayPM03um: Bool
   @Binding var displayPM05um: Bool
   @Binding var displayPM1um:  Bool
   @Binding var displayPM25um: Bool
   @Binding var displayPM5um:  Bool
   @Binding var displayPM10um: Bool
   
   @State private var didAppear: Bool = false  // only call on the 1rst time the view is created

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
            .animation(.linear(duration: 0.6), value: displayPM05um)
            .animation(.linear(duration: 0.6), value: displayPM1um)
            .animation(.linear(duration: 0.6), value: displayPM25um)
            .animation(.linear(duration: 0.6), value: displayPM5um)
            .animation(.linear(duration: 0.6), value: displayPM10um)
            .animation(.linear(duration: 0.6), value: viewModel.pmMeasurements)
            .chartScrollableAxes(.horizontal)
            .chartXVisibleDomain(length: 900) // 900 is 2.5 hours
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
            .padding(12)
            HStack {
               Spacer()
               causeAndGraphPickerView3()
            }  // HStack
         }       // ZStack
      }          // GroupBox
      .onAppear {
         if(!didAppear) {
            didAppear = true
            viewModel.addListenerForParticleCountsSizes()
         }
      }
      .onDisappear {
         viewModel.cancelCombineSubscriptions()
      }
   }
}

#Preview {

   @Previewable @State var displayPM03um = true
   @Previewable @State var displayPM05um = true
   @Previewable @State var displayPM1um  = true
   @Previewable @State var displayPM25um = true
   @Previewable @State var displayPM5um  = true
   @Previewable @State var displayPM10um = true

   ShowRealTimeLineGraphViewPM(
      displayPM03um: $displayPM03um,
      displayPM05um: $displayPM05um,
      displayPM1um:  $displayPM1um,
      displayPM25um: $displayPM25um,
      displayPM5um: $displayPM5um,
      displayPM10um: $displayPM10um
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
               Text(verbatim: "# > 0.3µm/.1L: \(ls.pm03um)")
               Text(verbatim: "# > 0.5µm/.1L: \(ls.pm05um)")
               Text(verbatim: "# > 1.0µm/.1L: \(ls.pm1um)")
               Text(verbatim: "# > 2.5µm/.1L: \(ls.pm25um)")
               Text(verbatim: "# >   5µm/.1L: \(ls.pm5um)")
               Text(verbatim: "# >  10µm/.1L: \(ls.pm10um)")
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
         .frame(width: 150)
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
                  displayPM05um: $displayPM05um,
                  displayPM1um: $displayPM1um,
                  displayPM25um: $displayPM25um,
                  displayPM5um: $displayPM5um,
                  displayPM10um: $displayPM10um
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

