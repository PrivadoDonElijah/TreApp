import SwiftUI

struct PrivacyView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.green)
                    Text("Your privacy, protected.")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("TreApp never tracks profiles or sells your data.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    MetricCard(icon: "shield.fill", title: "Trackers blocked", value: "1,000", color: .red)
                    MetricCard(icon: "eye.slash.fill", title: "Data hidden/masked", value: "0", color: .orange)
                    MetricCard(icon: "checkmark.seal.fill", title: "Data encrypted", value: "0", color: .green)
                    MetricCard(icon: "lock.fill", title: "Searches private", value: "100%", color: .blue)
                }
            }
            .padding()
        }
    }
}
