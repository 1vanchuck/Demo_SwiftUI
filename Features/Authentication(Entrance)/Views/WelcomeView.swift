import SwiftUI

struct WelcomeView: View {
    var body: some View {
        VStack {
            Spacer()
            Image(systemName: "party.popper.fill").font(.system(size: 80)).foregroundStyle(.white)
            Text("Welcome to Party App").font(.largeTitle).fontWeight(.bold).foregroundStyle(.white).padding(.top, 20)
            Spacer()
            
            VStack(spacing: 15) {
                NavigationLink(destination: EnterPhoneNumberView()) {
                    Text("Continue with Phone Number")
                        .fontWeight(.semibold).frame(maxWidth: .infinity).padding().background(Color.white.opacity(0.2)).foregroundStyle(.white).cornerRadius(15)
                }
                NavigationLink(destination: LoginView()) {
                    Text("Continue with Email")
                        .fontWeight(.semibold).frame(maxWidth: .infinity).padding().background(Color.white).foregroundStyle(.black).cornerRadius(15)
                }
                Text("By continuing, you agree to our Privacy Policy and Terms of Service.")
                    .font(.caption).foregroundStyle(.white.opacity(0.7)).multilineTextAlignment(.center).padding(.top, 20)
            }
            .padding(.horizontal).padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(LinearGradient(colors: [Color.purple.opacity(0.8), Color.black], startPoint: .top, endPoint: .bottom))
        .ignoresSafeArea()
    }
}

#Preview {
    NavigationStack {
        WelcomeView()
    }
}
