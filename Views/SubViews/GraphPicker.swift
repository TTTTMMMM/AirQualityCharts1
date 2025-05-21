import SwiftUI

struct GraphPickerView: View {
   
   @Binding var displayTemperature: Bool
   @Binding var displayHumidity: Bool
   @Binding var displayECO2: Bool
   @Binding var displayTVOC: Bool
   
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
            Text("ECO2")
         }
         .scaleEffect(0.8)
         Toggle(isOn: $displayTVOC){
            Text("TVOC")
         }
         .scaleEffect(0.8)
      }
      .background(Color.gray.opacity(0.1))
      .clipShape(RoundedRectangle(cornerRadius: 10))
      .frame(width: 160)
      .padding(.trailing, 45)
//      .padding(.top, 65)
   }
}

#Preview {
   GraphPickerView(displayTemperature: .constant(true), displayHumidity: .constant(true), displayECO2: .constant(true), displayTVOC: .constant(true))
}
