import Foundation

struct DonationOption: Identifiable {
    let id = UUID()
    let amount: Double
    let treesPlanted: Int
    
    static let presetOptions: [DonationOption] = [
        DonationOption(amount: 5.0, treesPlanted: 5),
        DonationOption(amount: 10.0, treesPlanted: 10),
        DonationOption(amount: 25.0, treesPlanted: 25),
        DonationOption(amount: 50.0, treesPlanted: 50),
        DonationOption(amount: 100.0, treesPlanted: 100)
    ]
}

enum PaymentMethod: String, CaseIterable, Identifiable {
    case applePay = "Apple Pay"
    case creditCard = "Credit Card"
    case paypal = "PayPal"
    case gcash = "GCash"
    
    var id: String { self.rawValue }
    
    var iconName: String {
        switch self {
        case .applePay: return "apple.logo"
        case .creditCard: return "creditcard.fill"
        case .paypal: return "dollarsign.circle.fill"
        case .gcash: return "iphone.radiowaves.left.and.right"
        }
    }
}
