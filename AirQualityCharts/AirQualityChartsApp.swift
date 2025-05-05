//
//  AirQualityChartsApp.swift
//  AirQualityCharts
//
//  Created by antonio morales on 4/24/25.
//

import SwiftUI

@main
struct AirQualityChartsApp: App {
   let clvmArrayInitial: [ChartListViewModel] = clvmArray
    var body: some Scene {
        WindowGroup {
            ContentView(clvmArray: clvmArrayInitial)
//              .environmentObject(AQViewModel())
        }
    }
}
