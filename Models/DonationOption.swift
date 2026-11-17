
import Foundation

struct DonationOption: Identifiable {
    let id = UUID()
    let amount: Double
    let treesPlanted: Int

    static let presetOptions: [DonationOption] = [
        DonationOption(amount: 5, treesPlanted: 5),
        DonationOption(amount: 10, treesPlanted: 10),
        DonationOption(amount: 25, treesPlanted: 25),
        DonationOption(amount: 50, treesPlanted: 50),
        DonationOption(amount: 100, treesPlanted: 100)
    ]
}

enum PaymentMethod: String, CaseIterable, Identifiable {
    case applePay = "Apple Pay"
    case creditCard = "Credit Card"
    case paypal = "PayPal"
    case gcash = "GCash"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .applePay:
            return "apple.logo"
        case .creditCard:
            return "creditcard.fill"
        case .paypal:
            return "p.circle.fill"
        case .gcash:
            return "iphone.gen3.radiowaves.left.and.right"
        }
    }
}
