import SwiftUI

struct CauseAndGraphPickerView: View {
   
   @Binding var displayTemperature: Bool
   @Binding var displayHumidity: Bool
   @Binding var displayECO2: Bool
   @Binding var displayTVOC: Bool
   
   var body: some View {
      VStack(alignment: .leading, spacing: 10) {
//         CausePicker()
         CauseMenu()
         GraphPickerView(displayTemperature: $displayTemperature, displayHumidity: $displayHumidity, displayECO2: $displayECO2, displayTVOC: $displayTVOC)
      }
      .padding(.top, 60)
      
   }
}

#Preview {
   @Previewable @State var displayTemperature = true
   @Previewable @State var displayHumidity = true
   @Previewable @State var displayECO2 = true
   @Previewable @State var displayTVOC = true
   CauseAndGraphPickerView(displayTemperature: $displayTemperature, displayHumidity: $displayHumidity, displayECO2: $displayECO2, displayTVOC: $displayTVOC)
}
