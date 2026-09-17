import SwiftUI

struct DonationView: View {
    @StateObject private var donationManager = DonationManager.shared
    @State private var selectedOption: DonationOption = DonationOption.presetOptions[1]
    @State private var selectedPaymentMethod: PaymentMethod = .applePay
    @State private var isProcessing: Bool = false
    @State private var showSuccessAlert: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "leaf.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 64, height: 64)
                            .foregroundColor(.green)
                        
                        Text("Plant Trees with Every Donation")
                            .font(.title2)
                            .bold()
                            .multilineTextAlignment(.center)
                        
                        Text("Every $1.00 donated plants 1 real-world tree to restore deforested areas.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top)

                    // Impact Counter Card
                    VStack(spacing: 8) {
                        Text("YOUR IMPACT TODAY")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                        
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text("\(selectedOption.treesPlanted)")
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundColor(.green)
                            Text("Trees")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(16)
                    .padding(.horizontal)

                    // Amount Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Select Donation Amount")
                            .font(.headline)
                            .padding(.horizontal)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(DonationOption.presetOptions) { option in
                                    Button(action: {
                                        selectedOption = option
                                    }) {
                                        VStack(spacing: 4) {
                                            Text("$\(Int(option.amount))")
                                                .font(.headline)
                                            Text("\(option.treesPlanted) 🌲")
                                                .font(.caption)
                                        }
                                        .frame(width: 80, height: 64)
                                        .background(selectedOption.id == option.id ? Color.green : Color(.systemGray6))
                                        .foregroundColor(selectedOption.id == option.id ? .white : .primary)
                                        .cornerRadius(12)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }

                    // Payment Method Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Select Payment Method")
                            .font(.headline)
                            .padding(.horizontal)

                        VStack(spacing: 8) {
                            ForEach(PaymentMethod.allCases) { method in
                                Button(action: {
                                    selectedPaymentMethod = method
                                }) {
                                    HStack {
                                        Image(systemName: method.iconName)
                                            .frame(width: 24)
                                            .foregroundColor(.green)
                                        Text(method.rawValue)
                                            .font(.body)
                                        Spacer()
                                        if selectedPaymentMethod == method {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                        }
                                    }
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Donate Button
                    Button(action: processDonation) {
                        HStack {
                            if isProcessing {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Donate $\(Int(selectedOption.amount)) & Plant \(selectedOption.treesPlanted) Trees")
                                    .font(.headline)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                    }
                    .disabled(isProcessing)
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
            .navigationTitle("Donate")
            .alert("Thank You!", isPresented: $showSuccessAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Your donation of $\(Int(selectedOption.amount)) was successful using \(selectedPaymentMethod.rawValue). You just helped plant \(selectedOption.treesPlanted) trees!")
            }
        }
    }

    private func processDonation() {
        isProcessing = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            isProcessing = false
            donationManager.recordDonation(amount: selectedOption.amount, trees: selectedOption.treesPlanted)
            showSuccessAlert = true
        }
    }
}

