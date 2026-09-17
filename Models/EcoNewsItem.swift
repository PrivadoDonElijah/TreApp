import Foundation

struct EcoNewsItem: Identifiable {
    let id = UUID()
    let title: String
    let source: String
    let timeAgo: String
    let category: String
}

