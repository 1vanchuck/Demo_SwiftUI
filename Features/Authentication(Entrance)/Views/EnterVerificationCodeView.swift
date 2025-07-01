import SwiftUI

struct EnterVerificationCodeView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("Enter code")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("We sent a code to +1\(viewModel.phoneNumber)")
                    .foregroundStyle(.gray)

                TextField("Verification code", text: $viewModel.verificationCode)
                    .font(.title3)
                    .keyboardType(.numberPad)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                
                Spacer()

                Button(action: {
                    viewModel.checkVerificationCode()
                }) {
                    Text("Confirm")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundStyle(.white)
                        .background(Color.purple)
                        .cornerRadius(15)
                }
            }
            .padding()
            .navigationTitle("Verify number")
            
            if viewModel.isLoading {
                Color.black.opacity(0.4).ignoresSafeArea()
                ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
            }
        }
        .navigationDestination(isPresented: $viewModel.shouldNavigateToProfileDetails) {
            EnterNameAndDateView()
        }
    }
}

#Preview {
    NavigationStack {
        EnterVerificationCodeView()
            .environmentObject(AuthViewModel())
    }
}
