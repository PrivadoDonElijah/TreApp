
import Combine
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import Foundation

@MainActor
final class DonationManager: ObservableObject {
    
    static let shared = DonationManager()
    
    // MARK: - Published Impact
    
    @Published private(set) var totalTreesPlanted = 0
    @Published private(set) var totalDonatedAmount = 0.0
    @Published private(set) var impactError: String?
    
    // MARK: - Firestore Listener
    
    private var impactListener: ListenerRegistration?
    private var listenerID = UUID()
    
    // MARK: - Firebase References
    
    private var profileDocument: DocumentReference? {
        
        guard FirebaseApp.app() != nil,
              let uid = Auth.auth().currentUser?.uid else {
            return nil
        }
        
        return Firestore.firestore()
            .collection("profiles")
            .document(uid)
    }
    
    // MARK: - Record Donation
    
    // Call only after payment has been verified.
    // paymentID must uniquely identify the verified payment.
    
    func recordDonation(
        amount: Double,
        trees: Int,
        forest: ForestReserve,
        paymentID: String
    ) async throws {
        
        guard let profileDocument else {
            throw DonationError.signInRequired
        }
        
        guard amount > 0, trees > 0 else {
            throw DonationError.invalidDonation
        }
        
        guard !paymentID.isEmpty else {
            throw DonationError.invalidPayment
        }
        
        let donationDocument = profileDocument
            .collection("donations")
            .document(paymentID)
        
        let forestID: String
        
        switch forest {
        case .sierraMadre:
            forestID = "sierra_madre"
        case .calabarzon:
            forestID = "calabarzon"
        case .cebu:
            forestID = "cebu"
        case .mindanao:
            forestID = "mindanao"
        }
        
        let database = Firestore.firestore()
        
        _ = try await database.runTransaction { transaction, errorPointer in
            
            do {
                let existing = try transaction.getDocument(
                    donationDocument
                )
                
                // Prevent counting the same payment twice.
                if existing.exists {
                    return true
                }
                
                transaction.setData([
                    "amount": amount,
                    "trees": trees,
                    "forestID": forestID,
                    "forestName": forest.rawValue,
                    "forestLocation": forest.location,
                    "paymentID": paymentID,
                    "status": "verified",
                    "createdAt": FieldValue.serverTimestamp()
                ], forDocument: donationDocument)
                
                transaction.setData([
                    "treesPlanted": FieldValue.increment(Int64(trees)),
                    "totalDonatedAmount": FieldValue.increment(amount)
                ], forDocument: profileDocument, merge: true)
                
                return true
                
            } catch {
                errorPointer?.pointee = error as NSError
                return false
            }
        }
    }
    
    // MARK: - Observe Impact
    
    func observeImpact() {
        
        stopObservingImpact()
        
        guard let profileDocument else {
            impactError = "Sign in to view your impact."
            return
        }
        
        let currentListenerID = listenerID
        
        impactListener = profileDocument.addSnapshotListener {
            [weak self] snapshot, error in
            
            let profile = snapshot?.data()
            
            let trees = max(
                0,
                profile?["treesPlanted"] as? Int ?? 0
            )
            
            let amount =
            profile?["totalDonatedAmount"] as? Double ?? 0
            
            let errorMessage = error?.localizedDescription
            
            Task { @MainActor [weak self] in
                
                guard let self,
                      self.listenerID == currentListenerID else {
                    return
                }
                
                if let errorMessage {
                    self.impactError =
                    "Couldn’t load your impact. \(errorMessage)"
                    return
                }
                
                self.totalTreesPlanted = trees
                self.totalDonatedAmount = amount
                self.impactError = nil
            }
        }
    }
    
    // MARK: - Stop Observing
    
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
        case invalidDonation
        case invalidPayment
        
        nonisolated var errorDescription: String? {
            switch self {
            case .signInRequired:
                return "Please sign in again to record your donation."
                
            case .invalidDonation:
                return "Enter the donation amount and tree count."
                
            case .invalidPayment:
                return "A verified payment reference is required."
            }
        }
    }
}
