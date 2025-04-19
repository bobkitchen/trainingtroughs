import SwiftUI
import Charts

struct WorkoutDetailView: View {
    @StateObject private var vm: WorkoutDetailViewModel
    @State private var showGraphs = false

    init(workout: Workout) {
        _vm = StateObject(wrappedValue: WorkoutDetailViewModel(activity: workout))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                header

                Divider()

                aggregates

                if showGraphs {
                    charts
                } else {
                    Button("Show graphs") { showGraphs = true }
                        .buttonStyle(.bordered)
                        .padding(.top, 12)
                }
            }
            .padding()
        }
        .task { await vm.load() }
        .navigationTitle("Workout")
    }

    // MARK: ─ sub‑views --------------------------------------------------------

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(vm.activity.name)
                .font(.title3).bold()
            Text(vm.activity.date, style: .date)
                .foregroundStyle(.secondary)
            Text("\(Int(vm.activity.duration/60)) min • \(Int(vm.activity.tss)) TSS")
                .font(.footnote).foregroundStyle(.secondary)
        }
    }

    private var aggregates: some View {
        Grid(horizontalSpacing: 32, verticalSpacing: 8) {
            GridRow {
                stat("Avg HR",  vm.detail?.avgHr,    suffix:"bpm")
                stat("Max HR",  vm.detail?.maxHr,    suffix:"bpm")
            }
            GridRow {
                stat("Avg Pwr", vm.detail?.avgPower, suffix:"W")
                stat("Max Pwr", vm.detail?.maxPower, suffix:"W")
            }
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder private func stat(_ title:String,
                                   _ value:Double?,
                                   suffix:String)->some View {
        VStack {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text(value.map{ String(format:"%.0f", $0) } ?? "—")
                .font(.headline)
            Text(suffix).font(.caption2).foregroundStyle(.secondary)
        }
    }

    // Placeholder – graphs can be added once streams are fetched lazily
    private var charts: some View {
        Text("Graphs coming soon …")
            .frame(maxWidth:.infinity, minHeight:120)
            .background(.quaternary.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius:12))
    }
}
