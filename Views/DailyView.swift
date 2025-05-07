import SwiftUI
import Charts

struct DailyView: View {

   @StateObject var vm = AQViewModel()
   @State var selectedDate = Date()
   @State var charted = false
   
   var body: some View {
      VStack (alignment: .center) {
         datePickerSection
      }
      Spacer()
         .fullScreenCover(isPresented: $charted) {
            dailyChartSheet(
               selectedDate: selectedDate,
               dateFormatter: dateFormatter,
               dateFormatter2: dateFormatter2
            )
         }
         .padding()
         .background(Color.white)
   }
}


#Preview {
   DailyView()
}

extension DailyView {
   
   var bounds: ClosedRange<Date> {
      let start = Calendar.current.date(from: DateComponents(
         timeZone: .current, year: 2025, month: 4, day: 17))!
      let end = Date()
      return start...end
   }
   
   var dateFormatter: DateFormatter {
      let formatter = DateFormatter()
      formatter.dateFormat = "MMM dd, yyyy"
      return formatter
   }
   
   var dateFormatter2: DateFormatter {
      let formatter = DateFormatter()
      formatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
      return formatter
   }
   
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
            vm.getAQMeasurements(dt: 1746135360)
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
   
   func backButton () -> some View {
      Button(action: {
         charted.toggle()
      }, label: {
         Image(systemName: "clear")
            .foregroundStyle(.white)
            .font(.title3)
            .padding(1)
      })
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(Color.blue)
   }
   
   func theDailyChart() -> some View {
      GroupBox {
         Text("Daily Environment Chart for \(self.dateFormatter.string(from: self.selectedDate))")
            .font(.title2)
         Chart {
            ForEach (vm.aqMeasurements, id: \.id)  { measurement in
               // temperature
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
               // humidity
               PointMark(
                  x: .value("timestamp", measurement.timeString),
                  y: .value("humidity", measurement.humidity)
               )
               .symbol(.square)
               .foregroundStyle(.black)
               LineMark(
                  x: .value("timestamp", measurement.timeString),
                  y: .value("humidity", measurement.humidity),
                  series: .value("humidity", "B")
               )
               .foregroundStyle(Color.black)
               // eCO2
               PointMark(
                  x: .value("timestamp", measurement.timeString),
                  y: .value("ECO2", measurement.unBiasedECO2)
               )
               .symbol(.circle)
               .foregroundStyle(.blue)
               LineMark(
                  x: .value("timestamp", measurement.timeString),
                  y: .value("ECO2", measurement.unBiasedECO2),
                  series: .value("unBiasedECO2", "C")
               )
               .foregroundStyle(Color.blue)
               // tVOC
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
         .chartLegend(position: .top, alignment: .leading, spacing: 8)
         //         .chartForegroundStyleScale(
         //            ["Temperature": Color.accentColor,
         //             "Humidity": Color.black,
         //             "eCO2": Color.blue,
         //             "tVOC": Color.red
         //            ]
         //         )
         .chartForegroundStyleScale(["eCO2": Color.blue])
         .chartYAxis {
            AxisMarks(position: .leading)
         }
      }
      .padding(1)
   }
   
   func dailyChartSheet(selectedDate: Date, dateFormatter: DateFormatter, dateFormatter2: DateFormatter) -> some View {
      
      VStack () {
         backButton()
         theDailyChart()
         Spacer()
      }
      .background(Color.white)
   }
 }
