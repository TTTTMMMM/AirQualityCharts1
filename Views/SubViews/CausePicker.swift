//
//  CausePicker.swift
//  AirQualityCharts
//
//  Created by antonio morales on 5/21/25.
//

import SwiftUI

struct CausePicker: View {
   @State var selection: String? = nil
   let causes: [String] = ["Wood Stove", "Cleaners", "Pollen", "Cooking", "Breath", "Other", "Unknown"]
   
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
         }
         if (selection != nil ) {
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
