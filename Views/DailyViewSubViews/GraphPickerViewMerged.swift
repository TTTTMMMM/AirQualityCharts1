import SwiftUI

struct GraphPickerViewMerged: View {
   
   @Binding var displayTemperature: Bool
   @Binding var displayHumidity: Bool
   @Binding var displayECO2: Bool
   @Binding var displayTVOC: Bool
   @Binding var displayPM03um: Bool
   @Binding var displayPM100s: Bool
   
   var body: some View {
      VStack (alignment: .leading) {
         Toggle(isOn: $displayTemperature){
            Text("Temperature")
         }
         .scaleEffect(0.8)
         Toggle(isOn: $displayHumidity){
            Text("Humidity")
         }
         .scaleEffect(0.8)
         Toggle(isOn: $displayECO2){
            Text("CO₂")
         }
         .scaleEffect(0.8)
         Toggle(isOn: $displayTVOC){
            Text("TVOC")
         }
         .scaleEffect(0.8)
         Toggle(isOn: $displayPM03um){
            Text("0.3 µm")
         }
         .scaleEffect(0.8)
         Toggle(isOn: $displayPM100s){
            Text("PM10")
         }
         .scaleEffect(0.8)
      }
      .background(Color.gray.opacity(0.1))
      .clipShape(RoundedRectangle(cornerRadius: 10))
      .frame(width: 160)
   }
}

#Preview {
   GraphPickerViewMerged(
      displayTemperature: .constant(true),
      displayHumidity:    .constant(true),
      displayECO2:        .constant(true),
      displayTVOC:        .constant(true),
      displayPM03um:      .constant(true),
      displayPM100s:      .constant(true)
   )
}
