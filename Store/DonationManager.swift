import Combine
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import Foundation

@MainActor
final class DonationManager: ObservableObject {
    static let shared = DonationManager()

    @Published private(set) var totalTreesPlanted = 0
    @Published private(set) var totalDonatedAmount = 0.0
    @Published private(set) var impactError: String?

    private var impactListener: ListenerRegistration?
    private var listenerID = UUID()

    private var profileDocument: DocumentReference? {
        guard FirebaseApp.app() != nil,
              let uid = Auth.auth().currentUser?.uid else {
            return nil
        }

        return Firestore.firestore()
            .collection("profiles")
            .document(uid)
    }

    func recordDonation(amount: Double, trees: Int) async throws {
        guard let profileDocument else {
            throw DonationError.signInRequired
        }

        try await profileDocument.setData([
            "treesPlanted": FieldValue.increment(Int64(trees)),
            "totalDonatedAmount": FieldValue.increment(amount)
        ], merge: true)
    }

    func observeImpact() {
        stopObservingImpact()

        guard let profileDocument else {
            impactError = "Sign in to view your impact."
            return
        }

        let currentListenerID = listenerID

        impactListener = profileDocument.addSnapshotListener { [weak self] snapshot, error in
            let profile = snapshot?.data()
            let trees = max(0, profile?["treesPlanted"] as? Int ?? 0)
            let amount = profile?["totalDonatedAmount"] as? Double ?? 0
            let errorMessage = error?.localizedDescription

            Task { @MainActor [weak self] in
                guard let self, self.listenerID == currentListenerID else { return }

                if let errorMessage {
                    self.impactError = "Couldn’t load your impact. \(errorMessage)"
                    return
                }

                self.totalTreesPlanted = trees
                self.totalDonatedAmount = amount
                self.impactError = nil
            }
        }
    }

    func stopObservingImpact() {
        listenerID = UUID()
        impactListener?.remove()
        impactListener = nil
        totalTreesPlanted = 0
        totalDonatedAmount = 0
        impactError = nil
    }

    private enum DonationError: LocalizedError {
        case signInRequired

        nonisolated var errorDescription: String? {
            "Please sign in again to record your donation."
        }
    }
}
