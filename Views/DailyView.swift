import SwiftUI
import Charts

struct DailyView: View {

   @StateObject var vm = AQViewModel()
   @State var selectedDate = Date()
   @State var charted = false
   @State var displayTemperature = true
   @State var displayHumidity = true
   @State var displayECO2 = true
   @State var displayTVOC = true

   private var bounds: ClosedRange<Date>!
   private var dateFormatter: DateFormatter!
   private var dateFormatter2: DateFormatter!

   init() {
      let start = Calendar.current.date(from: DateComponents(
         timeZone: .current, year: 2025, month: 4, day: 17))!
      let end = Date()
      self.bounds = start...end

      let formatter = DateFormatter()
      formatter.dateFormat = "MMM dd, yyyy"
      self.dateFormatter = formatter
      
      let formatter2 = DateFormatter()
      formatter2.dateFormat = "YYYY-MM-dd HH:mm:ss"
      self.dateFormatter2 = formatter2
      }
   
   var body: some View {
      VStack (alignment: .center) {
         datePickerSection
      }
      Spacer()
         .fullScreenCover(isPresented: $charted) {
            dailyChartSheet()
               .task {
                  do {
                     try await vm.getAQMeasurements(dt: 1746135360)
                  }
                  catch {
                     print(error.localizedDescription)
                  }
               }
         }
         .padding()
         .background(Color.white)
   }
}


#Preview {
   DailyView()
}

extension DailyView {
   
   private var datePickerSection: some View {
      HStack(alignment: .center, spacing: 20) {
         DatePicker("",
                    selection: $selectedDate,
                    in: bounds,
                    displayedComponents: [.date])
         .datePickerStyle(
            GraphicalDatePickerStyle()
         )
         Button(action: {
            charted.toggle()
//            vm.getAQMeasurements(dt: 1746135360)
         },
                label: {
            Text("Graph Data for\n \(self.dateFormatter.string(from: self.selectedDate))")
               .font(.headline)
               .foregroundStyle(.white)
         })
         .padding(10)
         .font(.title)
         .background(Color.accentColor)
         .clipShape(RoundedRectangle(cornerRadius: 10))
         .shadow(color: Color.black.opacity(0.9), radius: 10, x: 0, y: 5)
      }
      .padding(40)
   }
   
   func showLineGraphs() -> some View {
      GroupBox {
         Text("Daily Environment Chart for \(self.dateFormatter.string(from: self.selectedDate))")
            .font(.title2)
         Chart {
            ForEach (vm.aqMeasurements)  { measurement in
               if displayTemperature {
                  PointMark(
                     x: .value("timestamp", measurement.timeString),
                     y: .value("temperature", measurement.temperature)
                  )
                  .symbol(.triangle)
                  .foregroundStyle(.green)
                  LineMark(
                     x: .value("timestamp", measurement.timeString),
                     y: .value("temperature", measurement.temperature),
                     series: .value("temperature", "A")
                  )
                  .foregroundStyle(Color.green)
               }
               if displayHumidity {
                  PointMark(
                     x: .value("timestamp", measurement.timeString),
                     y: .value("humidity", measurement.humidity)
                  )
                  .symbol(.circle)
                  .foregroundStyle(.black)
                  LineMark(
                     x: .value("timestamp", measurement.timeString),
                     y: .value("humidity", measurement.humidity),
                     series: .value("humidity", "B")
                  )
                  .foregroundStyle(Color.black)
               }
               if displayECO2 {
                  PointMark(
                     x: .value("timestamp", measurement.timeString),
                     y: .value("ECO2", measurement.unBiasedECO2)
                  )
                  .symbol(.cross)
                  .foregroundStyle(.blue)
                  LineMark(
                     x: .value("timestamp", measurement.timeString),
                     y: .value("ECO2", measurement.unBiasedECO2),
                     series: .value("unBiasedECO2", "C")
                  )
                  .foregroundStyle(Color.blue)
               }
               if displayTVOC {
                  PointMark(
                     x: .value("timestamp", measurement.timeString),
                     y: .value("tVOC", measurement.tVOC)
                  )
                  .symbol(.diamond)
                  .foregroundStyle(.red)
                  LineMark(
                     x: .value("timestamp", measurement.timeString),
                     y: .value("tVOC", measurement.tVOC),
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
         .animation(.linear(duration: 2.6), value: vm.aqMeasurements)
         .chartScrollableAxes(.horizontal)
         .chartXVisibleDomain(length: 10)
         .chartLegend(position: .top, alignment: .leading, spacing: 8)
//         .chartForegroundStyleScale(
//            ["Temperature": Color.accentColor,
//             "Humidity": Color.black,
//             "eCO2": Color.blue,
//             "tVOC": Color.red
//            ]
//         )
         .chartForegroundStyleScale(["eCO2": Color.blue, "Temperature": Color.accentColor, "Humidity": Color.black])
         .chartYAxis {
            AxisMarks(position: .leading)
         }
      }
      .padding(12)
   }
   
   private var backButton: some View {
      Button(action: {
         charted.toggle()
         Task {
               do {
                  try await vm.clearAQMeasurements()
               }
               catch {
                  print(error.localizedDescription)
               }
         }
      }, label: {
         Image(systemName: "clear")
            .font(.title2)
            .padding(6)
            .foregroundStyle(.primary)
            .background(.thickMaterial)
            .cornerRadius(10)
            .shadow(radius: 4)
      })
      .padding(.leading, 45)
   }
   
   private var graphPicker: some View {
         VStack (alignment: .leading) {
            Toggle(isOn: $displayTemperature){
               Text("Temperature")
            }
            .scaleEffect(0.8)
            Toggle(isOn: $displayHumidity){
               Text("Humidity")
            }
            .scaleEffect(0.8)
            Toggle(isOn: $displayECO2){
               Text("ECO2")
            }
            .scaleEffect(0.8)
            Toggle(isOn: $displayTVOC){
               Text("TVOC")
            }
            .scaleEffect(0.8)
         }
         .background(Color.gray.opacity(0.1))
         .clipShape(RoundedRectangle(cornerRadius: 10))
         .frame(width: 160)
         .padding(.trailing, 45)
         .padding(.top, 65)
   }
   
   func dailyChartSheet() -> some View {
         VStack () {
            showLineGraphs()
         }
         .ignoresSafeArea()
         .background(.ultraThinMaterial)
         .overlay(backButton, alignment: .topLeading)
         .overlay(graphPicker, alignment: .topTrailing)
   }
   
 }
