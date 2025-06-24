import SwiftUI
import PhotosUI

struct AddProfilePicView: View {
    // 1. Получаем ViewModel из общего окружения
    @EnvironmentObject var viewModel: AuthViewModel
    
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var profileImage: UIImage? = nil

    var body: some View {
        ZStack {
            VStack(spacing: 30) {
                Text("Add a profile pic")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("So other people can see you on the guest list")
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.center)

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
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                        
                        Image(systemName: "camera.fill")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .frame(width: 50, height: 50)
                            .background(Color.purple)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color(.systemBackground), lineWidth: 4))
                            .offset(x: -5, y: -5)
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
                    Image(systemName: "lightbulb.fill").foregroundStyle(.yellow)
                    VStack(alignment: .leading) {
                        Text("Pro tip").fontWeight(.bold)
                        Text("You're 10x more likely to get invited to parties if you have a profile picture 😉")
                    }
                }
                .padding().background(Color(.secondarySystemBackground)).cornerRadius(10)
                
                Spacer()

                Button("Next") {
                    Task {
                        await viewModel.completeProfileSetup(image: profileImage)
                    }
                }
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.purple)
                .foregroundStyle(.white)
                .cornerRadius(15)
            }
            .padding()
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Skip") {
                        Task {
                            await viewModel.completeProfileSetup(image: nil)
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
            // Модификатор .alert здесь больше не нужен
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
            // Для превью нужно вручную "положить" ViewModel в окружение
            .environmentObject(AuthViewModel())
    }
}
