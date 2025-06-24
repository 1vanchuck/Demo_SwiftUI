import SwiftUI

struct EnterNameAndDateView: View {
    // 1. ИЗМЕНЕНИЕ: Получаем ViewModel из окружения
    @EnvironmentObject var viewModel: AuthViewModel
    
    @State private var name: String = ""
    @State private var birthDate: Date = Calendar.current.date(byAdding: .year, value: -18, to: Date()) ?? Date()
    
    private func isFormValid() -> Bool {
        return name.trimmingCharacters(in: .whitespaces).count >= 2
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Text("Tell us about yourself")
                    .font(.largeTitle).fontWeight(.bold)
                    .padding(.bottom, 20)
                
                TextField("Your Name", text: $name)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                
                DatePicker("Your birthday", selection: $birthDate, in: ...Date(), displayedComponents: .date)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                
                Spacer()
                
                Button("Next") {
                    Task {
                        await viewModel.saveUserNameAndBirthDate(name: name, birthDate: birthDate)
                    }
                }
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(isFormValid() ? Color.purple : Color.gray)
                .foregroundStyle(.white)
                .cornerRadius(15)
                .disabled(!isFormValid())
            }
            .padding()
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $viewModel.shouldNavigateToAddProfilePic) {
                // 2. ИЗМЕНЕНИЕ: Вызываем следующий экран БЕЗ viewModel
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
            // 3. ИЗМЕНЕНИЕ: Для превью нужно вручную "положить" ViewModel в окружение
            .environmentObject(AuthViewModel())
    }
}
