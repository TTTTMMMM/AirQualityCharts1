import SwiftUI

struct GraphPickerViewPM: View {
   
   @Binding var displayPM03um: Bool
   @Binding var displayPM10s:  Bool
   @Binding var displayPM25s:  Bool
   @Binding var displayPM100s: Bool
   
   var body: some View {
      VStack (alignment: .leading) {
         Toggle(isOn: $displayPM03um){
            Text("0.3 µm")
         }
         .scaleEffect(0.8)
         Toggle(isOn: $displayPM10s){
            Text("PM1.0")
         }
         .scaleEffect(0.8)
         Toggle(isOn: $displayPM25s){
            Text("PM2.5")
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
   GraphPickerViewPM(
      displayPM03um: .constant(true),
      displayPM10s: .constant(true),
      displayPM25s: .constant(true),
      displayPM100s: .constant(true)
   )
}
