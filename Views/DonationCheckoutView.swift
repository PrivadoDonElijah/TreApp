
import SwiftUI

struct DonationCheckoutView: View {
    let amount: Int
    let paymentMethod: PaymentMethod

    @Environment(\.dismiss) private var dismiss

    @State private var cardholder = ""
    @State private var email = ""
    @State private var showNotice = false

    private let green = Color(
        red: 0.17,
        green: 0.77,
        blue: 0.36
    )

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {

                    Image(systemName: paymentMethod.icon)
                        .font(.system(size: 48))
                        .foregroundStyle(green)
                        .padding(.top, 24)

                    Text(paymentMethod.rawValue)
                        .font(.title.bold())

                    Text("Donation Checkout")
                        .foregroundStyle(.secondary)

                    VStack(spacing: 12) {
                        Text("$\(amount).00")
                            .font(
                                .system(
                                    size: 40,
                                    weight: .bold
                                )
                            )

                        Text(
                            "\(amount) trees will be added to your impact after payment confirmation."
                        )
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(24)
                    .background(green.opacity(0.08))
                    .clipShape(
                        RoundedRectangle(cornerRadius: 16)
                    )

                    paymentDetails

                    Button {
                        showNotice = true
                    } label: {
                        Text("Continue to Secure Payment")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(green)
                            .foregroundStyle(.white)
                            .clipShape(
                                RoundedRectangle(cornerRadius: 14)
                            )
                    }

                    Text("No payment will be charged in this prototype.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
            }
            .navigationTitle("Checkout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .alert(
                "Payment Setup Required",
                isPresented: $showNotice
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(
                    "Connect \(paymentMethod.rawValue) to a real payment gateway before accepting donations."
                )
            }
        }
    }

    @ViewBuilder
    private var paymentDetails: some View {
        switch paymentMethod {

        case .applePay:
            VStack(spacing: 12) {
                Image(systemName: "lock.shield.fill")
                    .font(.largeTitle)

                Text("Apple Pay")
                    .font(.headline)

                Text(
                    "Apple Pay uses your saved Wallet cards once merchant payment processing is configured."
                )
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            }

        case .creditCard:
            VStack(alignment: .leading, spacing: 14) {
                Text("Cardholder Information")
                    .font(.headline)

                TextField(
                    "Cardholder Name",
                    text: $cardholder
                )
                .textContentType(.name)
                .textFieldStyle(.roundedBorder)

                TextField(
                    "Email Address",
                    text: $email
                )
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
                .textFieldStyle(.roundedBorder)

                Text(
                    "Card number, expiration date, and CVV must be collected through a secure payment provider."
                )
                .font(.footnote)
                .foregroundStyle(.secondary)
            }

        case .paypal:
            VStack(spacing: 12) {
                Text("Pay with PayPal")
                    .font(.headline)

                Text(
                    "A secure PayPal checkout will open after payment integration is configured."
                )
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            }

        case .gcash:
            VStack(spacing: 12) {
                Text("Pay with GCash")
                    .font(.headline)

                Text(
                    "A secure GCash checkout will open after payment integration is configured."
                )
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    DonationCheckoutView(
        amount: 10,
        paymentMethod: .applePay
    )
}
