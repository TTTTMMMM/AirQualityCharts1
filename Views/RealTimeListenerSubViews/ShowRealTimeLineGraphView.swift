import SwiftUI
import Charts

struct ShowRealTimeLineGraphView: View {
   
   @StateObject var viewModel = AirQualityViewModel()
   @Binding var displayTemperature: Bool
   @Binding var displayHumidity: Bool
   @Binding var displayECO2: Bool
   @Binding var displayTVOC: Bool
   @State private var didAppear: Bool = false  // only call on the 1rst time the view is created

   var selectedDateHour: Date = Date()
   var startTime = Calendar.current.date(
      byAdding: .hour,
      value: -2,
      to: Date())
   
   private var dateFormatter: DateFormatter {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "MMM dd, yyyy"
      return dateFormatter
   }
   
   private var dateFormatter2: DateFormatter {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "HH:mm"
      return dateFormatter
   }
   
   var body: some View {
      GroupBox {
         Text("Real-time Chart for \(self.dateFormatter.string(from: self.selectedDateHour)) starting at \(self.dateFormatter2.string(from: self.startTime!))")
            .font(.title2)

         ZStack (alignment: .top) {
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
                     .foregroundStyle(Color.black)
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
               }
            }
            .transition(.opacity)
            .animation(.linear(duration: 0.6), value: displayTemperature)
            .animation(.linear(duration: 0.6), value: displayHumidity)
            .animation(.linear(duration: 0.6), value: displayECO2)
            .animation(.linear(duration: 0.6), value: displayTVOC)
            .animation(.linear(duration: 0.6), value: viewModel.aqMeasurements)
            .chartScrollableAxes(.horizontal)
            .chartXVisibleDomain(length: 240)
            .chartLegend(position: .top, alignment: .leading, spacing: 8)
            .chartForegroundStyleScale(
               ["Temperature": Color.accentColor,
                "Humidity": Color.black,
                "eCO2": Color.blue,
                "tVOC": Color.red
               ]
            )
            .chartXAxis {
               AxisMarks(
                  // label every 15 mins
                  values: .automatic(desiredCount: 15)
               ) { mark in
                  if mark.index % 15 == 0 {
                     AxisValueLabel()
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
         }
      }
      .onAppear {
         if(!didAppear) {
            didAppear = true
            viewModel.addListenerForAQSamples()
         }
      }
      .onDisappear {
         viewModel.cancelCombineSubscriptions()
      }
   }
}

#Preview {

   @Previewable @State var displayTemperature = true
   @Previewable @State var displayHumidity = true
   @Previewable @State var displayECO2 = true
   @Previewable @State var displayTVOC = true
   
   ShowRealTimeLineGraphView(
      displayTemperature: $displayTemperature,
      displayHumidity: $displayHumidity,
      displayECO2: $displayECO2,
      displayTVOC: $displayTVOC
   )
}

extension ShowRealTimeLineGraphView {
   func LastSampleView() -> some View {
      var dateFormatter2: DateFormatter {
         let dateFormatter = DateFormatter()
         dateFormatter.dateFormat = "YYYY-MMM-dd HH:mm"
         return dateFormatter
      }
      
      return
         VStack (alignment: .leading) {
            Text("Last Sample")
               .font(.subheadline)
               .foregroundStyle(.black)
               .frame(maxWidth: .infinity, alignment: .center)
            Text(verbatim: "ID: \(viewModel.lastSample?.id ?? 0)")
            Text(verbatim: "Temperature: \(viewModel.lastSample?.temperature ?? 0)°F")
            Text(verbatim: "Humidity: \(viewModel.lastSample?.humidity ?? 0)%")
            Text(verbatim: "ECO2: \(viewModel.lastSample?.eCO2 ?? 0) -> \(viewModel.lastSample?.unBiasedECO2AndScaled ?? 0)")
            Text(verbatim: "TVOC: \(viewModel.lastSample?.tVOC ?? 0) -> \(viewModel.lastSample?.scaledTVOC ?? 0)")
            Text("\(dateFormatter2.string(from: viewModel.lastSample?.dt ?? .now))")
         }
         .font(.caption2)
         .padding(6)
         .background(Color.gray.opacity(0.1))
         .clipShape(RoundedRectangle(cornerRadius: 10))
         .overlay(
            RoundedRectangle(cornerRadius: 6)
               .stroke(.black, lineWidth: 1)
         )
         .frame(width: 130)
         .transition(.opacity)
         .animation(.linear(duration: 0.6), value: viewModel.lastSample)
      }
}

extension ShowRealTimeLineGraphView {
   
   func causeAndGraphPickerView2() -> some View {
      
      return
         HStack (alignment: .top) {
            LastSampleView()
               .padding(.top, 14)
            VStack(alignment: .leading, spacing: 10) {
               Text("Freebies Left: \(viewModel.dailyFreebiesLeft ?? 0)")
                  .font(.caption2)
                  .padding(4)
               CauseMenuView()
               GraphPickerView(
                  displayTemperature: $displayTemperature,
                  displayHumidity: $displayHumidity,
                  displayECO2: $displayECO2,
                  displayTVOC: $displayTVOC
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

