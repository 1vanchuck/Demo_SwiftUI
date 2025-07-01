import SwiftUI

struct EnterNameAndDateView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    @State private var selectedGender: Gender? = nil
    let brandPrimaryColor = Color(red: 0.45, green: 0.3, blue: 0.8)
    
    enum Gender: String, CaseIterable {
        case male = "Male"
        case female = "Female"
        case other = "Other"
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                
                VStack {
                    Image(systemName: "person.text.rectangle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(brandPrimaryColor)
                        .padding(.bottom, 10)
                    
                    Text("Tell us about yourself")
                        .font(.largeTitle).fontWeight(.bold)
                    
                    Text("This will be displayed on your profile.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)

                VStack(spacing: 15) {
                    TextField("Your Name", text: $viewModel.name)
                        .modifier(FormFieldStyle(brandColor: brandPrimaryColor))
                    
                    HStack {
                        Text("Your birthday")
                        Spacer()
                        Text(viewModel.birthDate, style: .date)
                    }
                    .modifier(FormFieldStyle(brandColor: brandPrimaryColor))
                    .overlay(
                        DatePicker("", selection: $viewModel.birthDate, in: ...Date(), displayedComponents: .date)
                            .blendMode(.destinationOver)
                    )
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Gender")
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .padding(.leading)
                        
                        HStack(spacing: 10) {
                            ForEach(Gender.allCases, id: \.self) { gender in
                                Button(action: {
                                    selectedGender = gender
                                }) {
                                    Text(gender.rawValue)
                                        .fontWeight(.semibold)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(selectedGender == gender ? brandPrimaryColor : Color.clear)
                                        .foregroundColor(selectedGender == gender ? .white : .primary)
                                        .cornerRadius(10)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(selectedGender == gender ? Color.clear : Color.gray.opacity(0.4), lineWidth: 1)
                                        )
                                }
                            }
                        }
                    }
                }
                .padding(.top, 20)
                
                Spacer(minLength: 20)
                
                Button("Next") {
                    Task { await viewModel.saveUserNameAndBirthDate() }
                }
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.isProfileFormValid ? brandPrimaryColor : Color.gray.opacity(0.4))
                .foregroundStyle(.white)
                .cornerRadius(15)
                .disabled(!viewModel.isProfileFormValid)
            }
            .padding()
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationDestination(isPresented: $viewModel.shouldNavigateToAddProfilePic) {
                // AddProfilePicView()
            }
            
            if viewModel.isLoading {
                Color.black.opacity(0.4).ignoresSafeArea()
                ProgressView().tint(.white)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct FormFieldStyle: ViewModifier {
    let brandColor: Color
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
            .tint(brandColor)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.4), lineWidth: 1)
            )
    }
}

#Preview {
    NavigationStack {
        EnterNameAndDateView()
            .environmentObject(AuthViewModel())
    }
}
