import SwiftUI

struct GraphPickerViewPM: View {
   
   @Binding var displayPM03um: Bool
   @Binding var displayPM05um: Bool
   @Binding var displayPM1um:  Bool
   @Binding var displayPM25um: Bool
   
   var body: some View {
      VStack (alignment: .leading) {
         Toggle(isOn: $displayPM03um){
            Text("0.3 um")
         }
         .scaleEffect(0.8)
         Toggle(isOn: $displayPM05um){
            Text("0.5 um")
         }
         .scaleEffect(0.8)
         Toggle(isOn: $displayPM1um){
            Text("1.0 um")
         }
         .scaleEffect(0.8)
         Toggle(isOn: $displayPM25um){
            Text("2.5 um")
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
      displayPM05um: .constant(true),
      displayPM1um: .constant(true),
      displayPM25um: .constant(true))
}
