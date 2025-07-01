import SwiftUI
import PhotosUI

struct AddProfilePicView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var profileImage: UIImage? = nil
    
    let brandPrimaryColor = Color(red: 0.45, green: 0.3, blue: 0.8)

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                
                VStack {
                    Text("Add a profile pic")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("So other people can see you on the guest list")
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.vertical, 20)

                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    ZStack(alignment: .bottomTrailing) {
                        Group {
                            if let profileImage {
                                Image(uiImage: profileImage)
                                    .resizable()
                                    .scaledToFill()
                            } else {
                                Circle()
                                    .fill(Color(.secondarySystemBackground))
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 80))
                                            .foregroundStyle(.gray.opacity(0.5))
                                    )
                            }
                        }
                        .frame(width: 200, height: 200)
                        .clipShape(Circle())
                        
                        Image(systemName: "camera.fill")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .frame(width: 50, height: 50)
                            .background(brandPrimaryColor)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color(.systemGroupedBackground), lineWidth: 4))
                    }
                }
                .onChange(of: selectedPhotoItem) {
                    Task {
                        if let data = try? await selectedPhotoItem?.loadTransferable(type: Data.self) {
                            profileImage = UIImage(data: data)
                        }
                    }
                }

                HStack(spacing: 15) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundStyle(brandPrimaryColor)
                        .font(.title2)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Pro tip").fontWeight(.bold)
                        Text("You're 10x more likely to get invited to parties if you have a profile picture 😉")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                .background(brandPrimaryColor.opacity(0.1))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(brandPrimaryColor.opacity(0.3), lineWidth: 1)
                )
                
                Spacer()

                Button("Next") {
                    Task {
                        await viewModel.completeProfileSetup(image: profileImage)
                    }
                }
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(brandPrimaryColor)
                .foregroundStyle(.white)
                .cornerRadius(15)
            }
            .padding()
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Skip") {
                        Task {
                            await viewModel.completeProfileSetup(image: nil)
                        }
                    }
                    .foregroundColor(brandPrimaryColor)
                }
            }
            .navigationDestination(isPresented: $viewModel.shouldNavigateToMainApp) {
                 MainView()
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
        AddProfilePicView()
            .environmentObject(AuthViewModel())
    }
}
