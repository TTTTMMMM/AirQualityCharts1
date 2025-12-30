import SwiftUI

struct CauseAndGraphPickerViewMerged: View {
   
   @Binding var displayTemperature: Bool
   @Binding var displayHumidity: Bool
   @Binding var displayECO2: Bool
   @Binding var displayTVOC: Bool
   @Binding var displayPM03um: Bool
   @Binding var displayPM100s: Bool
   @Binding var numLeft: Int?
   
   var body: some View {
      HStack (alignment: .top) {
         VStack(alignment: .leading, spacing: 10) {
            Text("Freebies Left: \(numLeft ?? 0)")
               .font(.caption2)
               .padding(4)
            GraphPickerViewMerged(
               displayTemperature: $displayTemperature,
               displayHumidity: $displayHumidity,
               displayECO2: $displayECO2,
               displayTVOC: $displayTVOC,
               displayPM03um: $displayPM03um,
               displayPM100s: $displayPM100s
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
   @Previewable @State var displayTemperature = true
   @Previewable @State var displayHumidity = true
   @Previewable @State var displayECO2 = true
   @Previewable @State var displayTVOC = true
   @Previewable @State var displayPM03um = false
   @Previewable @State var displayPM100s = true
   @Previewable @State var left: Int? = 8007
   
   CauseAndGraphPickerViewMerged(
      displayTemperature: $displayTemperature,
      displayHumidity: $displayHumidity,
      displayECO2: $displayECO2,
      displayTVOC: $displayTVOC,
      displayPM03um: $displayPM03um,
      displayPM100s: $displayPM100s,
      numLeft: $left
   )
}
