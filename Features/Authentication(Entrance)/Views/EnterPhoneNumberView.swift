import SwiftUI

struct EnterPhoneNumberView: View {
    @Environment(\.dismiss) var dismiss
    // Этот экран НАЧИНАЕТ флоу, поэтому он СОЗДАЕТ свой viewModel.
    // Но мы передадим его дальше через окружение, а не вручную.
    @StateObject private var viewModel = AuthViewModel()
    @State private var isNavigationActive = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // ... (весь UI остается без изменений) ...
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
        // ИЗМЕНЕНИЕ: Убираем передачу viewModel в инициализатор
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
        // ВАЖНО: Делаем viewModel доступным для следующего экрана в иерархии
        .environmentObject(viewModel)
    }
}
