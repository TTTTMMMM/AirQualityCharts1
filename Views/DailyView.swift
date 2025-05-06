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
            ChartScreen(
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
   
   func ChartScreen(selectedDate: Date, dateFormatter: DateFormatter, dateFormatter2: DateFormatter) -> some View {

      VStack () {
         Button(action: {
            charted.toggle()
         }, label: {
            Image(systemName: "clear")
               .foregroundStyle(.white)
               .font(.largeTitle)
               .padding(1)
         })
         .frame(maxWidth: .infinity, alignment: .leading)
         .background(Color.blue)
         Text("\(self.dateFormatter.string(from: self.selectedDate))")
            .font(.title)
            .foregroundStyle(.black)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity)
            .background(Color.yellow)
         Chart {
            ForEach (vm.aqMeasurements, id: \.id)  { measurement in
               LineMark(
                  x: .value("Datetime", measurement.timeString),
                  y: .value("Temp", measurement.temperature)
               )
            }
         }
//         Grid(alignment: .trailing, horizontalSpacing: 35, verticalSpacing: 10) {
//            ForEach(vm.aqMeasurements) {measurement in
//               GridRow {
//                  Text(verbatim: "\(measurement.id)")
//                     .bold()
//                     .font(.title2)
//                  Text("\(dateFormatter2.string(from: Date(timeIntervalSince1970: measurement.dt)))")
//                  Text("\(measurement.temperature, specifier: "%.1f")")
//                  Text("\(measurement.humidity, specifier: "%.1f")%")
//                  Text(verbatim: "\(measurement.eCO2)")
//                  Text("\(measurement.tVOC)")
//               }
//               .padding(.horizontal)
//            }
//         }
         .padding(20)
         Spacer()
      }
      .background(Color.white)
   }
}
