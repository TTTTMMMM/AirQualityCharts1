import SwiftUI

struct ListelementStyleView: View {
   let nameOfImage: String
   let textToDisplayOnListElement: String
    var body: some View {
       HStack {
          Image(nameOfImage)
             .resizable()
             .frame(width: 30, height: 30)
             .clipShape(Circle())
             .overlay{
                Circle()
                   .stroke(Color.black, lineWidth: 1)
             }
             .shadow(radius: 10)
             .padding()
          Text(textToDisplayOnListElement)
       }
    }
}

#Preview {
   
   ListelementStyleView(nameOfImage: "Line-Graph", textToDisplayOnListElement: "Daily Trend") 
}
