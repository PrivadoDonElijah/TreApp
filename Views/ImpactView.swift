import SwiftUI

struct ImpactView: View {
    @ObservedObject private var donationManager = DonationManager.shared

    private let targetCarbonOffset = 1_000.0

    // Demo conversion factors per donated tree.
    private let carbonKgPerTree = 20.0
    private let carMilesPerTree = 50.0
    private let oxygenLbsPerTree = 100.0
    private let energyKWhPerTree = 30.0
    private let forestSquareMetersPerTree = 4.0

    private var treesPlanted: Int {
        donationManager.totalTreesPlanted
    }

    private var totalCarbonOffset: Double {
        Double(treesPlanted) * carbonKgPerTree
    }

    private var progressRatio: Double {
        min(totalCarbonOffset / targetCarbonOffset, 1)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    impactRing

                    if let error = donationManager.impactError {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(error)
                                .font(.footnote)
                                .foregroundStyle(.secondary)

                            Button("Retry", action: donationManager.observeImpact)
                        }
                    }

                    Text("Trees supported: \(treesPlanted.formatted())")
                        .font(.headline)

                    impactMetrics
                    milestones
                }
                .padding()
            }
            .navigationTitle("Your Impact")
        }
        .onAppear(perform: donationManager.observeImpact)
        .onDisappear(perform: donationManager.stopObservingImpact)
    }

    private var impactRing: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color.green.opacity(0.15), lineWidth: 16)

                if progressRatio > 0 {
                    Circle()
                        .trim(from: 0, to: progressRatio)
                        .stroke(
                            LinearGradient(
                                colors: [.green, .mint],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 16, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                }

                VStack(spacing: 4) {
                    Text(totalCarbonOffset.formatted())
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)

                    Text("kg CO₂ Estimated Offset")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(20)
            }
            .frame(width: 200, height: 200)
            .padding(.top, 12)
            .animation(.easeOut(duration: 0.5), value: progressRatio)

            Text("Goal: \(targetCarbonOffset.formatted()) kg CO₂")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            Color(uiColor: .secondarySystemBackground),
            in: RoundedRectangle(cornerRadius: 20)
        )
    }

    private var impactMetrics: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Estimated Impact")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                MetricCard(
                    icon: "car.fill",
                    title: "Car Miles Saved",
                    value: "\(estimate(carMilesPerTree)) mi",
                    color: .blue
                )

                MetricCard(
                    icon: "leaf.fill",
                    title: "Oxygen Produced",
                    value: "\(estimate(oxygenLbsPerTree)) lbs",
                    color: .green
                )

                MetricCard(
                    icon: "bolt.fill",
                    title: "Energy Saved",
                    value: "\(estimate(energyKWhPerTree)) kWh",
                    color: .yellow
                )

                MetricCard(
                    icon: "square.grid.2x2.fill",
                    title: "Forest Area",
                    value: "\(estimate(forestSquareMetersPerTree)) m²",
                    color: .mint
                )
            }

            Text("Environmental figures use demo estimates per donated tree.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private var milestones: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Milestones")
                .font(.headline)

            VStack(spacing: 12) {
                milestone("Plant First 10 Trees", current: Double(treesPlanted), goal: 10)
                Divider()
                milestone("Offset 500 kg CO₂", current: totalCarbonOffset, goal: 500)
                Divider()
                milestone("Offset 1,000 kg CO₂", current: totalCarbonOffset, goal: targetCarbonOffset)
            }
            .padding()
            .background(
                Color(uiColor: .secondarySystemBackground),
                in: RoundedRectangle(cornerRadius: 16)
            )
        }
    }

    private func estimate(_ perTree: Double) -> String {
        (Double(treesPlanted) * perTree).formatted()
    }

    private func milestone(
        _ title: String,
        current: Double,
        goal: Double
    ) -> some View {
        let isCompleted = current >= goal
        let percentage = Int(min(current * 100 / goal, 100).rounded(.down))

        return MilestoneRow(
            title: title,
            subtitle: isCompleted ? "Achieved" : "In Progress (\(percentage)%)",
            isCompleted: isCompleted,
            icon: isCompleted ? "checkmark.circle.fill" : "clock.fill"
        )
    }
}

struct MilestoneRow: View {
    let title: String
    let subtitle: String
    let isCompleted: Bool
    let icon: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(isCompleted ? Color.green : Color.orange)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body.weight(.semibold))

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
    }
}

#Preview {
    ImpactView()
}
