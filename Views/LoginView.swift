import SwiftUI

struct LoginView: View {
    @Binding var isLoggedIn: Bool
    
    
    @AppStorage("userEmail") private var userEmail: String = ""
    
    @State private var email = ""
    @State private var password = ""
    @State private var isSigningUp = false
    @State private var errorMessage = ""

    // Password validation rules
    private var hasMinLength: Bool { password.count >= 8 }
    private var hasUppercase: Bool { password.range(of: "[A-Z]", options: .regularExpression) != nil }
    private var hasLowercase: Bool { password.range(of: "[a-z]", options: .regularExpression) != nil }
    private var hasNumber: Bool { password.range(of: "[0-9]", options: .regularExpression) != nil }
    private var hasSpecialChar: Bool { password.range(of: "[!@#$%^&*(),.?\":{}|<>]", options: .regularExpression) != nil }
    
    private var isPasswordStrong: Bool {
        hasMinLength && hasUppercase && hasLowercase && hasNumber && hasSpecialChar
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer(minLength: 40)

                // Header / Logo
                VStack(spacing: 10) {
                    Image(systemName: "leaf.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.green)

                    Text("TreApp")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Every search plants a tree for everywhere.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

                // Input Fields
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(.gray)
                        TextField("Email Address", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

                    HStack {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.gray)
                        SecureField("Password", text: $password)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

                    // Password Strength Checklist
                    if !password.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Password Requirements:")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)

                            RequirementRow(title: "At least 8 characters", isMet: hasMinLength)
                            RequirementRow(title: "At least 1 uppercase letter (A-Z)", isMet: hasUppercase)
                            RequirementRow(title: "At least 1 lowercase letter (a-z)", isMet: hasLowercase)
                            RequirementRow(title: "At least 1 number (0-9)", isMet: hasNumber)
                            RequirementRow(title: "At least 1 special character (!@#$%...)", isMet: hasSpecialChar)
                        }
                        .padding(.horizontal, 4)
                        .padding(.top, 4)
                    }

                    // Error Banner
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                .padding(.horizontal)

                // Primary Action Button
                Button(action: {
                    handleAuthentication()
                }) {
                    Text(isSigningUp ? "Create Account" : "Log In")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isPasswordStrong ? Color.green : Color.gray)
                        .cornerRadius(12)
                }
                .disabled(!isPasswordStrong)
                .padding(.horizontal)

                // Mode Switch
                Button(action: {
                    isSigningUp.toggle()
                    errorMessage = ""
                }) {
                    Text(isSigningUp ? "Already have an account? Log In" : "Don't have an account? Sign Up")
                        .font(.footnote)
                        .foregroundColor(.green)
                }

                Spacer(minLength: 40)
            }
        }
    }

    // Input Validation Logic
    private func handleAuthentication() {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedEmail.isEmpty {
            errorMessage = "Please enter an email address."
        } else if !trimmedEmail.contains("@") || !trimmedEmail.contains(".") {
            errorMessage = "Please enter a valid email address."
        } else if !isPasswordStrong {
            errorMessage = "Please fulfill all password strength requirements."
        } else {
            errorMessage = ""
            // Persist the user's email address
            userEmail = trimmedEmail
            
            withAnimation {
                isLoggedIn = true
            }
        }
    }
}

// Subview for Requirement Indicators
struct RequirementRow: View {
    let title: String
    let isMet: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: isMet ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isMet ? .green : .gray)
                .font(.caption)
            Text(title)
                .font(.caption)
                .foregroundColor(isMet ? .primary : .secondary)
        }
    }
}

#Preview {
    LoginView(isLoggedIn: .constant(false))
}

