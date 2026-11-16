import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

struct ProfileView: View {
    @Binding var isLoggedIn: Bool

    @AppStorage("userEmail") private var userEmail = "user@example.com"
    @AppStorage("isDarkMode") private var isDarkMode = false

    @State private var userName = "John Doe"
    @State private var treesPlanted = 0
    @State private var isEditingName = false
    @State private var tempName = ""
    @State private var isLoadingProfile = true
    @State private var isSavingName = false
    @State private var errorMessage = ""

    private var trimmedName: String {
        tempName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var profileDocument: DocumentReference? {
        guard FirebaseApp.app() != nil,
              let userId = Auth.auth().currentUser?.uid else {
            return nil
        }

        return Firestore.firestore()
            .collection("profiles")
            .document(userId)
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 16) {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.green)

                        VStack(alignment: .leading, spacing: 4) {
                            if isLoadingProfile {
                                ProgressView("Loading profile…")
                            } else if isEditingName {
                                HStack {
                                    TextField("Name", text: $tempName)
                                        .textFieldStyle(.roundedBorder)
                                        .disabled(isSavingName)

                                    Button(isSavingName ? "Saving…" : "Save") {
                                        Task {
                                            await saveName()
                                        }
                                    }
                                    .font(.subheadline.bold())
                                    .tint(.green)
                                    .buttonStyle(.borderless)
                                    .disabled(isSavingName || trimmedName.isEmpty)
                                }
                            } else {
                                HStack {
                                    Text(userName)
                                        .font(.headline)

                                    Button {
                                        tempName = userName
                                        errorMessage = ""
                                        isEditingName = true
                                    } label: {
                                        Image(systemName: "pencil")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                    .buttonStyle(.plain)
                                    .accessibilityLabel("Edit name")
                                }
                            }

                            Text(userEmail)
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            if !errorMessage.isEmpty {
                                Text(errorMessage)
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }

                Section("Your Impact") {
                    HStack {
                        Label("Trees Planted", systemImage: "leaf.fill")
                            .foregroundColor(.green)

                        Spacer()

                        Text(isLoadingProfile ? "…" : "\(treesPlanted)")
                            .bold()
                    }

                    HStack {
                        Label("Search Streak", systemImage: "flame.fill")
                            .foregroundColor(.orange)

                        Spacer()

                        Text("12 Days").bold()
                    }
                }

                Section("Preferences") {
                    Toggle(isOn: $isDarkMode) {
                        Label("Dark Mode", systemImage: "moon.fill")
                    }
                }

                Section {
                    Button(role: .destructive, action: signOut) {
                        Text("Log Out")
                            .bold()
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(isSavingName)
                }
            }
            .navigationTitle("Profile")
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .task {
                await loadProfile()
            }
        }
    }

    @MainActor
    private func loadProfile() async {
        isLoadingProfile = true
        defer { isLoadingProfile = false }

        guard let document = profileDocument else { return }

        do {
            let snapshot = try await document.getDocument()
            let profile = snapshot.data()

            userName = profile?["displayName"] as? String ?? "John Doe"
            treesPlanted = profile?["treesPlanted"] as? Int ?? 0
        } catch {
            errorMessage = "Could not load your profile: \(error.localizedDescription)"
        }
    }

    @MainActor
    private func saveName() async {
        let name = trimmedName
        guard !isSavingName, !name.isEmpty else { return }

        guard let document = profileDocument else {
            errorMessage = "Please log in again to save your profile."
            return
        }

        isSavingName = true
        errorMessage = ""
        defer { isSavingName = false }

        do {
            try await document.setData(["displayName": name], merge: true)
            userName = name
            isEditingName = false
        } catch {
            errorMessage = "Could not save your name: \(error.localizedDescription)"
        }
    }

    private func signOut() {
        guard FirebaseApp.app() != nil else {
            errorMessage = "Firebase is unavailable."
            return
        }

        do {
            try Auth.auth().signOut()
            userEmail = ""
            isLoggedIn = false
        } catch {
            errorMessage = "Could not log out: \(error.localizedDescription)"
        }
    }
}

#Preview {
    ProfileView(isLoggedIn: .constant(true))
}
