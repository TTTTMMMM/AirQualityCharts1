import SwiftUI

struct DatePickerSectionView: View {
   
   @Binding var selectedDate: Date
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
      dateFormatter.dateFormat = "MMM dd, yyyy"
      return dateFormatter
   }
   
   var body: some View {
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
}

#Preview {
   @Previewable @State var selectedDate: Date = Date()
   DatePickerSectionView(
      selectedDate: $selectedDate,
      charted: .constant(true),
      yearDataBegins: 2025,
      monthDataBegins: 9,
      dayDataBegins: 15)
}
