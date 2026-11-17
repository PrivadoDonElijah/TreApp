
import Foundation
import FirebaseFirestore

struct EcoNewsItem: Identifiable, Codable {
    @DocumentID var id: String?

    var title: String
    var source: String
    var category: String
    var summary: String
    var imageURL: String
    var articleURL: String
    var publishedAt: Date

    var articleLink: URL? {
        guard let url = URL(string: articleURL),
              ["https", "http"].contains(
                url.scheme?.lowercased() ?? ""
              ),
              url.host != nil else {
            return nil
        }
        return url
    }
}
