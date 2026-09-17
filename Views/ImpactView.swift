import SwiftUI

struct ImpactView: View {
    @State private var totalCarbonOffset: Double = 576.0
    @State private var targetCarbonOffset: Double = 1000.0
    
    var progressRatio: Double {
        min(totalCarbonOffset / targetCarbonOffset, 1.0)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // MARK: - Hero Impact Ring Summary
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .stroke(Color.green.opacity(0.15), lineWidth: 16)
                            
                            Circle()
                                .trim(from: 0, to: progressRatio)
                                .stroke(
                                    LinearGradient(colors: [.green, .mint], startPoint: .topLeading, endPoint: .bottomTrailing),
                                    style: StrokeStyle(lineWidth: 16, lineCap: .round)
                                )
                                .rotationEffect(.degrees(-90))
                                .animation(.easeOut(duration: 1.0), value: progressRatio)
                            
                            VStack(spacing: 4) {
                                Text("\(Int(totalCarbonOffset))")
                                    .font(.system(size: 40, weight: .bold, design: .rounded))
                                Text("kg CO₂ Offset")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .frame(width: 200, height: 200)
                        .padding(.top, 12)
                        
                        Text("Goal: \(Int(targetCarbonOffset)) kg CO₂ this year")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(20)
                    
                    // MARK: - Equivalence Metric Grid
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Real-World Impact")
                            .font(.headline)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            MetricCard(
                                icon: "car.fill",
                                title: "Car Miles Saved",
                                value: "1,430 mi",
                                color: .blue
                            )
                            
                            MetricCard(
                                icon: "leaf.fill",
                                title: "Oxygen Produced",
                                value: "2,880 lbs",
                                color: .green
                            )
                            
                            MetricCard(
                                icon: "bolt.fill",
                                title: "Energy Saved",
                                value: "850 kWh",
                                color: .yellow
                            )
                            
                            MetricCard(
                                icon: "square.grid.2x2.fill",
                                title: "Forest Area",
                                value: "120 sq.m",
                                color: .mint
                            )
                        }
                    }
                    
                    // MARK: - Milestone Progress List
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Milestones")
                            .font(.headline)
                        
                        VStack(spacing: 12) {
                            MilestoneRow(
                                title: "Plant First 10 Trees",
                                subtitle: "Achieved March 2026",
                                isCompleted: true,
                                icon: "checkmark.circle.fill"
                            )
                            Divider()
                            MilestoneRow(
                                title: "Offset 500 kg CO₂",
                                subtitle: "Achieved August 2026",
                                isCompleted: true,
                                icon: "checkmark.circle.fill"
                            )
                            Divider()
                            MilestoneRow(
                                title: "Offset 1,000 kg CO₂",
                                subtitle: "In Progress (57%)",
                                isCompleted: false,
                                icon: "clock.fill"
                            )
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(16)
                    }
                }
                .padding()
            }
            .navigationTitle("Your Impact")
        }
    }
}

// MARK: - Supporting Milestone Row
struct MilestoneRow: View {
    let title: String
    let subtitle: String
    let isCompleted: Bool
    let icon: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(isCompleted ? .green : .orange)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .fontWeight(.semibold)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
    }
}

#Preview {
    ImpactView()
}

