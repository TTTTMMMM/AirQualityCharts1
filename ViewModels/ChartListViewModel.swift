import Foundation
import SwiftUI

struct ChartListViewModel: Identifiable {
   let id = UUID().uuidString
   let imageName: String
   let listDisplayText: String
   let chartView: AnyView
}

let dailyView = ChartListViewModel(
   imageName: "Line-Graph",
   listDisplayText: "Daily Trend",
   chartView: AnyView(DailyView()))
let weeklyView = ChartListViewModel(
   imageName: "bar-chart",
   listDisplayText: "Weekly Trend",
   chartView: AnyView(WeeklyView()))
let dailyComparisonView = ChartListViewModel(
   imageName: "daily-comparison",
   listDisplayText: "Daily Comparison",
   chartView: AnyView(DailyComparisonView()))

let clvmArray: [ChartListViewModel] = [dailyView, weeklyView, dailyComparisonView]

