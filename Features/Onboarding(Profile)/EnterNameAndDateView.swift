import SwiftUI

struct EnterNameAndDateView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    // Убираем локальные состояния, используем состояния из ViewModel
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Text("Tell us about yourself")
                    .font(.largeTitle).fontWeight(.bold)
                    .padding(.bottom, 20)
                
                TextField("Your Name", text: $viewModel.name)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                
                DatePicker("Your birthday", selection: $viewModel.birthDate, in: ...Date(), displayedComponents: .date)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                
                Spacer()
                
                Button("Next") {
                    Task {
                        await viewModel.saveUserNameAndBirthDate()
                    }
                }
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.isProfileFormValid ? Color.purple : Color.gray)
                .foregroundStyle(.white)
                .cornerRadius(15)
                .disabled(!viewModel.isProfileFormValid)
            }
            .padding()
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $viewModel.shouldNavigateToAddProfilePic) {
                AddProfilePicView()
            }
            
            if viewModel.isLoading {
                Color.black.opacity(0.4).ignoresSafeArea()
                ProgressView().tint(.white)
            }
        }
    }
}

#Preview {
    NavigationStack {
        EnterNameAndDateView()
            .environmentObject(AuthViewModel())
    }
}
