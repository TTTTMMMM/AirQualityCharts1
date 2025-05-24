import SwiftUI

struct CauseAndGraphPickerView: View {
   
   @Binding var displayTemperature: Bool
   @Binding var displayHumidity: Bool
   @Binding var displayECO2: Bool
   @Binding var displayTVOC: Bool
      
   var body: some View {
      VStack(alignment: .leading, spacing: 10) {
         CauseMenuView()
         GraphPickerView(displayTemperature: $displayTemperature, displayHumidity: $displayHumidity, displayECO2: $displayECO2, displayTVOC: $displayTVOC)
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

#Preview {
   @Previewable @State var displayTemperature = true
   @Previewable @State var displayHumidity = true
   @Previewable @State var displayECO2 = true
   @Previewable @State var displayTVOC = true
   @Previewable @State var left = 33
   CauseAndGraphPickerView(
      displayTemperature: $displayTemperature,
      displayHumidity: $displayHumidity,
      displayECO2: $displayECO2,
      displayTVOC: $displayTVOC
   )
}
