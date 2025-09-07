import SwiftUI

struct CauseAndGraphPickerViewPM: View {
   
   @Binding var displayPM03um: Bool
   @Binding var displayPM05um: Bool
   @Binding var displayPM1um: Bool
   @Binding var displayPM25um: Bool
   @Binding var numLeft: Int?
      
   var body: some View {
      HStack (alignment: .top) {
//         LastSampleView()
//            .padding(.top, 44)
         VStack(alignment: .leading, spacing: 10) {
            Text("Freebies Left: \(numLeft ?? 0)")
               .font(.caption2)
               .padding(4)
            GraphPickerViewPM(
               displayPM03um: $displayPM03um,
               displayPM05um: $displayPM05um,
               displayPM1um:  $displayPM1um,
               displayPM25um: $displayPM25um
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
   @Previewable @State var displayPM03um = true
   @Previewable @State var displayPM05um = true
   @Previewable @State var displayPM1um = true
   @Previewable @State var displayPM25um = true
   @Previewable @State var left: Int? = 88
   
   CauseAndGraphPickerViewPM(
      displayPM03um: $displayPM03um,
      displayPM05um: $displayPM05um,
      displayPM1um:  $displayPM1um,
      displayPM25um: $displayPM25um,
      numLeft: $left
   )
}
