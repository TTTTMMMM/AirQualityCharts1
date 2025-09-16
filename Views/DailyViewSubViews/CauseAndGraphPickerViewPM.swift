import SwiftUI

struct CauseAndGraphPickerViewPM: View {
   
   @Binding var displayPM03um: Bool
   @Binding var displayPM10s:  Bool
   @Binding var displayPM25s:  Bool
   @Binding var displayPM100s: Bool
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
               displayPM10s: $displayPM10s,
               displayPM25s:  $displayPM25s,
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
   @Previewable @State var displayPM03um = true
   @Previewable @State var displayPM10s = true
   @Previewable @State var displayPM25s  = true
   @Previewable @State var displayPM100s = true
   @Previewable @State var left: Int? = 8007
   
   CauseAndGraphPickerViewPM(
      displayPM03um: $displayPM03um,
      displayPM10s: $displayPM10s,
      displayPM25s:  $displayPM25s,
      displayPM100s: $displayPM100s,
      numLeft: $left
   )
}
