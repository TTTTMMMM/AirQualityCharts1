import SwiftUI

struct AveragePickerView: View {
   
   @Binding var displayAvgTemperature: Bool
   @Binding var displayAvgHumidity: Bool
   @Binding var displayAvgECO2: Bool
   @Binding var displayAvgTVOC: Bool
   @Binding var displayAvgPm03um: Bool
   @Binding var displayAvgPm100s: Bool
   @Binding var numLeft: Int?
      
   var body: some View {
      HStack (alignment: .top) {
         VStack(alignment: .leading, spacing: 10) {
            Text("Freebies Left: \(numLeft ?? 0)")
               .font(.caption2)
               .padding(4)
            GraphPickerViewAvg(
               displayAvgTemperature: $displayAvgTemperature,
               displayAvgHumidity: $displayAvgHumidity,
               displayAvgECO2: $displayAvgECO2,
               displayAvgTVOC: $displayAvgTVOC,
               displayAvgPm03um: $displayAvgPm03um,
               displayAvgPm100s: $displayAvgPm100s
            )
         }
         .padding(3)
         .background(Color.gray.opacity(0.1))
         .clipShape(RoundedRectangle(cornerRadius: 10))
         .overlay(
             RoundedRectangle(cornerRadius: 6)
                 .stroke(.black, lineWidth: 1)
         )
         .padding(.top, 44)
         .padding(.trailing, 45)
      }

   }
}

#Preview {
   @Previewable @State var displayAvgTemperature = true
   @Previewable @State var displayAvgHumidity = true
   @Previewable @State var displayAvgECO2 = true
   @Previewable @State var displayAvgTVOC = true
   @Previewable @State var displayAvgPm03um = true
   @Previewable @State var displayAvgPm100s = true
   @Previewable @State var left: Int? = 495
   
   AveragePickerView(
      displayAvgTemperature: $displayAvgTemperature,
      displayAvgHumidity: $displayAvgHumidity,
      displayAvgECO2: $displayAvgECO2,
      displayAvgTVOC: $displayAvgTVOC,
      displayAvgPm03um: $displayAvgPm03um,
      displayAvgPm100s: $displayAvgPm100s,
      numLeft: $left
   )
}
