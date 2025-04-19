//
//  DashboardView.swift
//  TrainingTroughs
//
//  Working version – 19 Apr 2025
//

import SwiftUI
import Charts

struct DashboardView: View {

    // MARK: - Dependency
    @ObservedObject var viewModel: DashboardViewModel

    // Shared formatter for the FitnessPoint `date` string (“yyyy‑MM‑dd”)
    private static let df: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            // ── Header numbers ───────────────────────────────────────────────
            HStack(spacing: 20) {
                Text("Fitness (CTL): \(viewModel.currentCTL,  specifier: "%.1f")")
                Text("Fatigue (ATL): \(viewModel.currentATL,  specifier: "%.1f")")
                Text("Form (TSB): \(viewModel.currentTSB,  specifier: "%.1f")")
            }
            .padding(.horizontal)

            // ── Trend chart ──────────────────────────────────────────────────
            Chart {
                ForEach(viewModel.fitnessPoints) { point in
                    if point.ctl != 0 {                          // skip zero rows
                        LineMark(
                            x: .value("Date",  DashboardView.df.date(from: point.date) ?? Date()),
                            y: .value("CTL",   point.ctl)
                        )
                    }
                }
            }
            .frame(height: 220)
            .padding(.horizontal)
        }
        // 👉  Fetches CTL/ATL/TSB once when this view first appears.
        .task {
            await viewModel.refreshFitness()
            print("🔄 DashboardView.refreshFitness() complete")
        }
    }
}
