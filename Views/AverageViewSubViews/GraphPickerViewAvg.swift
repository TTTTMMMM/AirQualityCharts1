import SwiftUI

struct GraphPickerViewAvg: View {
   
   @Binding var displayAvgTemperature: Bool
   @Binding var displayAvgHumidity: Bool
   @Binding var displayAvgECO2: Bool
   @Binding var displayAvgTVOC: Bool
   @Binding var displayAvgPm03um: Bool
   @Binding var displayAvgPm100s: Bool
   
   var body: some View {
      VStack (alignment: .leading) {
         Toggle(isOn: $displayAvgTemperature){
            Text("Avg. Temp")
         }
         .scaleEffect(0.8)
         Toggle(isOn: $displayAvgHumidity){
            Text("Avg. Humid.")
         }
         .scaleEffect(0.8)
         Toggle(isOn: $displayAvgECO2){
            Text("Avg. CO₂")
         }
         .scaleEffect(0.8)
         Toggle(isOn: $displayAvgTVOC){
            Text("Avg. TVOC")
         }
         .scaleEffect(0.8)
         Toggle(isOn: $displayAvgPm03um){
            Text("Avg. PM 0.3 μm")
         }
         .scaleEffect(0.8)
         Toggle(isOn: $displayAvgPm100s){
            Text("Avg. PM 10.0s")
         }
         .scaleEffect(0.8)
      }
      .background(Color.gray.opacity(0.1))
      .clipShape(RoundedRectangle(cornerRadius: 10))
      .frame(width: 190)
   }
}

#Preview {
   GraphPickerViewAvg(
      displayAvgTemperature: .constant(true),
      displayAvgHumidity: .constant(true),
      displayAvgECO2: .constant(true),
      displayAvgTVOC: .constant(true),
      displayAvgPm03um: .constant(true),
      displayAvgPm100s: .constant(true)
   )
}
