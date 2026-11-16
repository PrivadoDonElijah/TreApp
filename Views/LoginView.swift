import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @Binding var isLoggedIn: Bool

    @AppStorage("userEmail") private var userEmail = ""

    @State private var email = ""
    @State private var password = ""
    @State private var isSigningUp = false
    @State private var isSubmitting = false
    @State private var errorMessage = ""

    private var trimmedEmail: String {
        email.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var hasMinLength: Bool { password.count >= 8 }
    private var hasUppercase: Bool {
        password.range(of: "[A-Z]", options: .regularExpression) != nil
    }
    private var hasLowercase: Bool {
        password.range(of: "[a-z]", options: .regularExpression) != nil
    }
    private var hasNumber: Bool {
        password.range(of: "[0-9]", options: .regularExpression) != nil
    }
    private var hasSpecialChar: Bool {
        let specialCharacters = "!@#$%^&*(),.?\":{}|<>"
        return password.contains { specialCharacters.contains($0) }
    }

    private var isPasswordStrong: Bool {
        hasMinLength && hasUppercase && hasLowercase && hasNumber && hasSpecialChar
    }

    private var canSubmit: Bool {
        !isSubmitting && !trimmedEmail.isEmpty && !password.isEmpty
            && (!isSigningUp || isPasswordStrong)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer(minLength: 40)

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

                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(.gray)

                        TextField("Email Address", text: $email)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .disabled(isSubmitting)

                    HStack {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.gray)

                        SecureField("Password", text: $password)
                            .textContentType(isSigningUp ? .newPassword : .password)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .disabled(isSubmitting)

                    if isSigningUp {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Password Requirements")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)

                            RequirementRow(title: "At least 8 characters", isMet: hasMinLength)
                            RequirementRow(title: "At least 1 uppercase letter (A–Z)", isMet: hasUppercase)
                            RequirementRow(title: "At least 1 lowercase letter (a–z)", isMet: hasLowercase)
                            RequirementRow(title: "At least 1 number (0–9)", isMet: hasNumber)
                            RequirementRow(title: "At least 1 special character (!@#$%...)", isMet: hasSpecialChar)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.horizontal)

                Button {
                    Task {
                        await handleAuthentication()
                    }
                } label: {
                    Text(isSubmitting ? "Please wait…" : (isSigningUp ? "Create Account" : "Log In"))
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(canSubmit ? Color.green : Color.gray)
                        .cornerRadius(12)
                }
                .disabled(!canSubmit)
                .padding(.horizontal)

                Button {
                    isSigningUp.toggle()
                    errorMessage = ""
                } label: {
                    Text(isSigningUp ? "Already have an account? Log In" : "Don't have an account? Sign Up")
                        .font(.footnote)
                        .foregroundColor(.green)
                }
                .disabled(isSubmitting)

                Spacer(minLength: 40)
            }
        }
    }

    @MainActor
    private func handleAuthentication() async {
        guard canSubmit else { return }

        isSubmitting = true
        errorMessage = ""
        defer { isSubmitting = false }

        do {
            let result: AuthDataResult

            if isSigningUp {
                result = try await Auth.auth().createUser(
                    withEmail: trimmedEmail,
                    password: password
                )
            } else {
                result = try await Auth.auth().signIn(
                    withEmail: trimmedEmail,
                    password: password
                )
            }

            userEmail = result.user.email ?? trimmedEmail
            password = ""

            withAnimation {
                isLoggedIn = true
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

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
