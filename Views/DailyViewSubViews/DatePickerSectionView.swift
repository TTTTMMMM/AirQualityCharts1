import SwiftUI

struct DatePickerSectionView: View {
   
   @Binding var selectedDate: Date
   @Binding var charted: Bool
   var yearDataBegins: Int
   var monthDataBegins: Int
   var dayDataBegins: Int

   private var bounds: ClosedRange<Date> {
      let calendar = Calendar.current
      let components = DateComponents(
         timeZone: .current,
         year: yearDataBegins,
         month: monthDataBegins,
         day: dayDataBegins)
      let fixedDate = calendar.date(from: components)!
      
      // Calculate one year before the current date
      // because ttl field is set to one year (approx) after data was written
      let oneYearAgo = Calendar.current.date(byAdding: .day, value: -367, to: Date())!
      // Determine later of the two dates
      let minimumDate = max(fixedDate, oneYearAgo)
      return minimumDate...Date()
   }
   
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
