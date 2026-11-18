
import SwiftUI

struct ForestPickerView: View {
    @ObservedObject private var forestManager =
        ForestSelectionManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Choose a Forest Reserve")
                .font(.headline)

            Text("Select where your donated trees will be allocated.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ForEach(ForestReserve.allCases) { forest in
                Button {
                    forestManager.selectedForest = forest
                } label: {
                    HStack(spacing: 12) {
                        Image(forest.imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 72, height: 65)
                            .clipped()
                            .clipShape(
                                RoundedRectangle(cornerRadius: 10)
                            )

                        VStack(alignment: .leading, spacing: 5) {
                            Text(forest.rawValue)
                                .font(.subheadline.bold())
                                .foregroundStyle(.primary)
                                .multilineTextAlignment(.leading)

                            Text(forest.location)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer(minLength: 4)

                        Image(
                            systemName:
                                forestManager.selectedForest == forest
                                ? "checkmark.circle.fill"
                                : "circle"
                        )
                        .font(.title2)
                        .foregroundStyle(.green)
                    }
                    .padding(10)
                    .background(
                        forestManager.selectedForest == forest
                        ? Color.green.opacity(0.10)
                        : Color(.secondarySystemBackground)
                    )
                    .clipShape(
                        RoundedRectangle(cornerRadius: 14)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}
