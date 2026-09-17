import SwiftUI
import Combine

class DonationManager: ObservableObject {
    static let shared = DonationManager()
    
    @Published var totalTreesPlanted: Int = 0
    @Published var totalDonatedAmount: Double = 0.0
    
    func recordDonation(amount: Double, trees: Int) {
        totalDonatedAmount += amount
        totalTreesPlanted += trees
    }
}
