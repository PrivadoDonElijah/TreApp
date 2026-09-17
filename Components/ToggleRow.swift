import SwiftUI
struct ToggleRow: View {
    var icon: String? = nil
    var title: String
    var subtitle: String? = nil
    @Binding var isOn: Bool
    var iconColor: Color = .blue

    var body: some View {
        HStack {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
            }
            VStack(alignment: .leading) {
                Text(title)
                    .font(.body)
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
    }
}

