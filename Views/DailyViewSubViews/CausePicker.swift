import SwiftUI


struct CausePicker: View {
   
   @StateObject var viewModel = DailyViewModel()
   
   @State var selection: String? = nil
   let causes: [String] = ["Wood Stove", "Cleaners", "Pollen", "Cooking", "Breath", "Other", "Unknown", "Remove Cause"]
   
   var body: some View {
      VStack (spacing: 2) {
         HStack {
            Text("Cause: ")
            Picker(
               selection: $selection,
               label:
                  HStack {
                     Text("Picker")
                     Text(selection ?? "")
                  }
                  .font(.headline)
               ,
               content: {
                  ForEach(causes, id: \.self, content: {
                     cause in
                     HStack {
                        Text(cause)
                        Image(systemName: "wind.snow")
                     }
                     .tag(cause)
                  })
               })
            .onReceive([self.selection].publisher.first()) { (reason) in
               guard let value = reason else { return }
               print("hi there \(reason) --> \(value)")
               Task {
//                  await viewModel.updateCause(reason: value)
               }
               print("bye bye without calling updateCause()")
            }
         }
         if (selection != nil) {
            Text("Remove Cause")
               .font(.subheadline)
               .onTapGesture {
                  selection = nil
               }
               .padding(12)
               .background(
                  Color.gray.opacity(0.1)
                     .cornerRadius(10)
                     .shadow(
                        color: Color.black.opacity(0.1),
                        radius: 5,
                        x: 0,
                        y: 5
                     )
               )
               .clipShape(RoundedRectangle(cornerRadius: 5))
         }
      }
   }
}

#Preview {
   CausePicker()
}
