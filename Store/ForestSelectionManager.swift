
import SwiftUI
import Combine

enum ForestReserve: String, CaseIterable, Identifiable, Codable {
    case sierraMadre = "Sierra Madre Mountain Range"
    case calabarzon = "Calabarzon Watershed Reserve"
    case cebu = "Cebu Hillylands Reforestation"
    case mindanao = "Mindanao Forest Corridor"

    var id: String { rawValue }

    var imageName: String {
        switch self {
        case .sierraMadre: "sierra_madre_forest"
        case .calabarzon: "calabarzon_forest"
        case .cebu: "cebu_forest"
        case .mindanao: "mindanao_forest"
        }
    }

    var location: String {
        switch self {
        case .sierraMadre: "Luzon, Philippines"
        case .calabarzon: "CALABARZON, Philippines"
        case .cebu: "Cebu, Philippines"
        case .mindanao: "Mindanao, Philippines"
        }
    }
}

final class ForestSelectionManager: ObservableObject {
    static let shared = ForestSelectionManager()

    @Published var selectedForest: ForestReserve {
        didSet {
            UserDefaults.standard.set(
                selectedForest.rawValue,
                forKey: "selectedForest"
            )
        }
    }

    private init() {
        let saved = UserDefaults.standard.string(
            forKey: "selectedForest"
        )

        selectedForest = ForestReserve(rawValue: saved ?? "")
            ?? .sierraMadre
    }
}
