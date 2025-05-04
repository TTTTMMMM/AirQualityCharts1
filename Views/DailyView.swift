import SwiftUI

struct DailyView: View {

   @EnvironmentObject private var vm: AQViewModel
   @State var selectedDate = Date()
   @State var bgColor = Color.white
   @State var charted = false
   
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
   
   var body: some View {
      VStack (alignment: .center) {
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
            .background(Color.black)
            .clipShape(RoundedRectangle(cornerRadius: 20))
         }
         .padding(10)
         Spacer()
            .frame(maxWidth: .infinity)
            .fullScreenCover(isPresented: $charted) {
               ChartScreen(
                  selectedDate: selectedDate,
                  dateFormatter: dateFormatter,
                  dateFormatter2: dateFormatter2
               )
            }
      }
      .padding()
      .background(bgColor)
   }
}

struct ChartScreen: View {
   
   @Environment(\.dismiss) private var dismiss
   @EnvironmentObject private var vm: AQViewModel
   @State var bg: Color = .green
   
   let selectedDate: Date
   let dateFormatter: DateFormatter
   let dateFormatter2: DateFormatter
   
   var body: some View {
      VStack () {
         Button(action: {
            self.dismiss()
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

         Grid(alignment: .trailing, horizontalSpacing: 35, verticalSpacing: 10) {
            ForEach(vm.aqMeasurements) {measurement in
               GridRow {
                  Text(verbatim: "\(measurement.id)")
                     .bold()
                     .font(.title2)
                  Text("\(dateFormatter2.string(from: Date(timeIntervalSince1970: measurement.dt)))")
                  Text("\(measurement.temperature, specifier: "%.1f")")
                  Text("\(measurement.humidity, specifier: "%.1f")%")
                  Text(verbatim: "\(measurement.eCO2)")
                  Text("\(measurement.tVOC)")
               }
               .padding(.horizontal)
            }
         }
         .padding(20)
         Spacer()
      }
      .background(bg)
   }
}



#Preview {
   var dateFormatter: DateFormatter {
      let formatter = DateFormatter()
      formatter.dateFormat = "MMM dd, yyyy"
      return formatter
   }
   var dateFormatter2: DateFormatter {
      let formatter = DateFormatter()
      formatter.dateFormat = "yy-MM-dd HH:mm:ss"
      return formatter
   }
//   ChartScreen(selectedDate: .now, dateFormatter: dateFormatter, dateFormatter2: dateFormatter2)
   DailyView()
      .environmentObject(AQViewModel())
}
