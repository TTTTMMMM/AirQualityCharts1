import SwiftUI

struct DatePickerSectionView: View {
   
   @Binding var selectedDate: Date
   @Binding var charted: Bool
   var title: String
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
   
   var body: some View {
      VStack {
         Text(title)
            .font(.headline)
         HStack(alignment: .center, spacing: 1) {
            DatePicker("",
                       selection: $selectedDate,
                       in: bounds,
                       displayedComponents: [.date])
            .datePickerStyle(
               GraphicalDatePickerStyle()
            )
         }
      }
   }
}

#Preview {
   @Previewable @State var selectedDate: Date = Date()
   DatePickerSectionView(
      selectedDate: $selectedDate,
      charted: .constant(true),
      title: "Pick a Start Date",
      yearDataBegins: 2025,
      monthDataBegins: 9,
      dayDataBegins: 15)
}
