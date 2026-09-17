import SwiftUI

struct ProfileView: View {
    @Binding var isLoggedIn: Bool
    
    // Persist profile data across app restarts
    @AppStorage("userName") private var userName: String = "John Doe"
    @AppStorage("userEmail") private var userEmail: String = "user@example.com"
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    // State for editing name inline
    @State private var isEditingName: Bool = false
    @State private var tempName: String = ""
    
    var body: some View {
        NavigationStack {
            List {
                // MARK: - Profile Header Section
                Section {
                    HStack(spacing: 16) {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.green)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            if isEditingName {
                                HStack {
                                    TextField("Name", text: $tempName)
                                        .textFieldStyle(.roundedBorder)
                                    
                                    Button("Save") {
                                        if !tempName.trimmingCharacters(in: .whitespaces).isEmpty {
                                            userName = tempName
                                        }
                                        isEditingName = false
                                    }
                                    .font(.subheadline.bold())
                                    .foregroundColor(.green)
                                }
                            } else {
                                HStack {
                                    Text(userName)
                                        .font(.headline)
                                    
                                    Button(action: {
                                        tempName = userName
                                        isEditingName = true
                                    }) {
                                        Image(systemName: "pencil")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            
                            Text(userEmail)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // MARK: - Impact Stats
                Section(header: Text("Your Impact")) {
                    HStack {
                        Label("Trees Planted", systemImage: "leaf.fill")
                            .foregroundColor(.green)
                        Spacer()
                        Text("24")
                            .bold()
                    }
                    
                    HStack {
                        Label("Search Streak", systemImage: "flame.fill")
                            .foregroundColor(.orange)
                        Spacer()
                        Text("12 Days")
                            .bold()
                    }
                }
                
                // MARK: - App Preferences
                Section(header: Text("Preferences")) {
                    Toggle(isOn: $isDarkMode) {
                        Label("Dark Mode", systemImage: "moon.fill")
                    }
                }
                
                // MARK: - Account Actions
                Section {
                    Button(role: .destructive, action: {
                        isLoggedIn = false
                    }) {
                        HStack {
                            Spacer()
                            Text("Log Out")
                                .bold()
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Profile")
            .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}

#Preview {
    ProfileView(isLoggedIn: .constant(true))
}
