import SwiftUI

struct EnterPhoneNumberView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = AuthViewModel()
    @State private var isNavigationActive = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Join the party")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Just for event updates. No spam ☝️")
                .foregroundStyle(.gray)

            HStack { /* ... */ }
            
            Text("Message & data rates may apply").font(.caption).foregroundStyle(.gray)
            
            Spacer()
            
            Button(action: {
                viewModel.sendVerificationCode()
                isNavigationActive = true
            }) {
                Text("Send code")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundStyle(.white)
            }
            .background(viewModel.isPhoneNumberValid ? Color.purple : Color.gray)
            .cornerRadius(15)
            .disabled(!viewModel.isPhoneNumberValid)
        }
        .padding()
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $isNavigationActive) {
            EnterVerificationCodeView()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.primary)
                }
            }
        }
        .environmentObject(viewModel)
    }
}
#Preview {
    NavigationStack {
        EnterPhoneNumberView()
    }
}
