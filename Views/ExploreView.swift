import SwiftUI

struct ExploreView: View {
    let newsItems = [
        EcoNewsItem(title: "Indonesia's Mangroves: Eco-System's Key Defense", source: "The Guardian", timeAgo: "1h ago", category: "Mangroves"),
        EcoNewsItem(title: "Patagonia adds 1,000 trees in July through Ecosia partnership", source: "Reuters", timeAgo: "3h ago", category: "Reforestation"),
        EcoNewsItem(title: "Ecosia targets 1,000 trees to reduce city temperatures by up to 2°C", source: "Ecosia News", timeAgo: "1d ago", category: "Climate")
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("ECO NEWS")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)

                ForEach(newsItems) { item in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(item.title)
                            .font(.headline)
                        HStack {
                            Text(item.source)
                            Text("•")
                            Text(item.timeAgo)
                            Spacer()
                            Text(item.category)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.green.opacity(0.15))
                                .cornerRadius(8)
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                }
            }
            .padding()
        }
    }
}

