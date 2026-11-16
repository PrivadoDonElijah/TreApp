import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SaveProfileView: View {
    @State private var displayName = ""
    @State private var status = ""
    @State private var isSaving = false

    private var trimmedName: String {
        displayName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField("Display name", text: $displayName)
                .textFieldStyle(.roundedBorder)
                .disabled(isSaving)

            Button(isSaving ? "Saving…" : "Save Profile") {
                Task {
                    await saveProfile()
                }
            }
            .disabled(isSaving || trimmedName.isEmpty)

            if !status.isEmpty {
                Text(status)
                    .font(.caption)
            }
        }
    }

    @MainActor
    private func saveProfile() async {
        guard let userId = Auth.auth().currentUser?.uid else {
            status = "Please log in first."
            return
        }

        isSaving = true
        status = ""
        defer { isSaving = false }

        do {
            try await Firestore.firestore()
                .collection("profiles")
                .document(userId)
                .setData(["displayName": trimmedName], merge: true)

            status = "Profile saved."
        } catch {
            status = "Save failed: \(error.localizedDescription)"
        }
    }
}
