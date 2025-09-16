import SwiftUI

struct HourlyPickerSectionView: View {
   
   @ObservedObject private var viewModel = AirQualityViewModel()
   @Binding var selectedDateHour: Date
   @Binding var numberOfHoursDuration: String
   @Binding var charted: Bool
   var yearDataBegins: Int
   var monthDataBegins: Int
   var dayDataBegins: Int
   
   private var bounds: ClosedRange<Date> {
      (Calendar.current.date(
         from: DateComponents(
            timeZone: .current,
            year: yearDataBegins,
            month: monthDataBegins,
            day: dayDataBegins))!)...Date()}
   
   private var dateFormatter: DateFormatter {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "MMM dd, yyyy HH:00"
      return dateFormatter
   }
   
   var body: some View {
      HStack(alignment: .center, spacing: 20) {
         DatePicker("",
                    selection: $selectedDateHour,
                    in: bounds
         )
         .datePickerStyle(
            GraphicalDatePickerStyle()
         )
         VStack {
            Menu("Number of hours: \(numberOfHoursDuration)") {
               ForEach(AirQualityViewModel.HoursDuration.allCases, id: \.self) { hoursDuration in
                  Button {
                     numberOfHoursDuration = hoursDuration.rawValue
                  } label: {
                     HStack{
                        Text(hoursDuration.rawValue)
                        Image(systemName: "clock")
                     }
                  }
               }
            }
            .font(.headline)
            .foregroundStyle(Color.accent)
            .padding(5)
            .clipShape(RoundedRectangle(cornerRadius: 1))
            Spacer()
            Button(action: {
               charted.toggle()
            },
                   label: {
               Text("Graph Data starting at\n \(self.dateFormatter.string(from: self.selectedDateHour))\n for the following \(numberOfHoursDuration) hour(s)")
                  .font(.headline)
                  .foregroundStyle(.white)
            })
            .padding(10)
            .font(.title)
            .background(Color.accentColor)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(color: Color.black.opacity(0.9), radius: 10, x: 0, y: 5)
         }
         .frame(width: .infinity, height:300)
      }
      .padding(40)
   }
}

#Preview {
   @Previewable @State var selectedDateHour: Date = Date()
   @Previewable @State var numberOfHoursDuration: String = "1"
   HourlyPickerSectionView(
      selectedDateHour: $selectedDateHour,
      numberOfHoursDuration: $numberOfHoursDuration,
      charted: .constant(true),
      yearDataBegins: 2025,
      monthDataBegins: 7,
      dayDataBegins: 28)
}
