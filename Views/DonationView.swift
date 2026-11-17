
import SwiftUI

struct DonationView: View {
    @State private var selectedAmount = 10
    @State private var selectedPayment: PaymentMethod = .applePay
    @State private var customAmount = ""
    @State private var isCustom = false
    @State private var showCheckout = false

    private let green = Color(
        red: 0.17,
        green: 0.77,
        blue: 0.36
    )

    private let amounts = [5, 10, 25, 50, 100]

    private var donationAmount: Int {
        isCustom ? (Int(customAmount) ?? 0) : selectedAmount
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                VStack(spacing: 10) {
                    Image(systemName: "leaf.circle.fill")
                        .font(.system(size: 45))
                        .foregroundStyle(green)

                    Text("Plant Trees with Every Donation")
                        .font(.title3.bold())
                        .multilineTextAlignment(.center)

                    Text("Every $1 in a demo donation adds 1 tree to your impact.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)

                VStack(spacing: 8) {
                    Text("TREES IN THIS DONATION")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)

                    HStack(alignment: .firstTextBaseline) {
                        Text("\(donationAmount)")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundStyle(green)

                        Text("Trees")
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(24)
                .background(green.opacity(0.09))
                .clipShape(
                    RoundedRectangle(cornerRadius: 18)
                )

                VStack(alignment: .leading, spacing: 12) {
                    Text("Select Donation Amount")
                        .font(.headline)

                    LazyVGrid(
                        columns: Array(
                            repeating: GridItem(.flexible()),
                            count: 3
                        ),
                        spacing: 10
                    ) {
                        ForEach(amounts, id: \.self) { amount in
                            Button {
                                selectedAmount = amount
                                isCustom = false
                            } label: {
                                VStack(spacing: 5) {
                                    Text("$\(amount)")
                                        .font(.headline)

                                    Text("\(amount) trees")
                                        .font(.caption2)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    selectedAmount == amount && !isCustom
                                    ? green
                                    : Color(.secondarySystemGroupedBackground)
                                )
                                .foregroundStyle(
                                    selectedAmount == amount && !isCustom
                                    ? Color.white
                                    : Color.primary
                                )
                                .clipShape(
                                    RoundedRectangle(cornerRadius: 12)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    Button {
                        isCustom = true
                    } label: {
                        Label(
                            "Custom Donation",
                            systemImage: "pencil"
                        )
                        .foregroundStyle(green)
                    }

                    if isCustom {
                        TextField(
                            "Enter amount in USD",
                            text: $customAmount
                        )
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Select Payment Method")
                        .font(.headline)

                    ForEach(PaymentMethod.allCases) { method in
                        Button {
                            selectedPayment = method
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: method.icon)
                                    .foregroundStyle(green)
                                    .frame(width: 24)

                                Text(method.rawValue)
                                    .foregroundStyle(.primary)

                                Spacer()

                                Image(
                                    systemName: selectedPayment == method
                                    ? "checkmark.circle.fill"
                                    : "circle"
                                )
                                .foregroundStyle(
                                    selectedPayment == method
                                    ? green
                                    : .gray
                                )
                            }
                            .padding(17)
                            .background(
                                Color(.secondarySystemGroupedBackground)
                            )
                            .clipShape(
                                RoundedRectangle(cornerRadius: 13)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }

                VStack(spacing: 12) {
                    HStack {
                        Text("Donation Total")
                        Spacer()
                        Text("$\(donationAmount).00")
                            .fontWeight(.bold)
                    }

                    HStack {
                        Text("Trees to Plant")
                        Spacer()
                        Text("\(donationAmount)")
                            .fontWeight(.bold)
                    }
                }
                .padding()
                .background(green.opacity(0.07))
                .clipShape(
                    RoundedRectangle(cornerRadius: 14)
                )

                Button {
                    showCheckout = true
                } label: {
                    Text("Continue with \(selectedPayment.rawValue)")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundStyle(.white)
                        .background(green)
                        .clipShape(
                            RoundedRectangle(cornerRadius: 14)
                        )
                }
                .disabled(donationAmount <= 0)
                .opacity(donationAmount <= 0 ? 0.5 : 1)

                Text("Your impact updates only after a verified payment.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
            }
            .padding()
        }
        .navigationTitle("Donate")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showCheckout) {
            DonationCheckoutView(
                amount: donationAmount,
                paymentMethod: selectedPayment
            )
        }
    }
}

#Preview {
    NavigationStack {
        DonationView()
    }
}
