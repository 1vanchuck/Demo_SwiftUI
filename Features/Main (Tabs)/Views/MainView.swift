import SwiftUI

struct MainView: View {
    @State private var selectedTab = 0
    @State private var isShowingCreateSheet = false
    private let createTabTag = 1
    
    // The main EventsViewModel is created here and owns the event data for the primary tabs.
    @StateObject private var eventsViewModel = EventsViewModel()

    var body: some View {
        TabView(selection: $selectedTab) {
            MapView()
                .tabItem { Label("Map", systemImage: "map") }
                .tag(0)

            Color.clear
                .tabItem { Label("Create", systemImage: "plus.circle.fill") }
                .tag(createTabTag)
            
            MyEventsView()
                .tabItem { Label("My Events", systemImage: "calendar") }
                .tag(2)

            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.crop.circle") }
                .tag(3)
        }
        // By injecting the ViewModel into the environment, we make it accessible
        // to all child views, ensuring they share the same state.
        .environmentObject(eventsViewModel)
        .onChange(of: selectedTab) { _, newTab in
            // This is a clever trick to use a tab bar item to trigger a modal sheet.
            if newTab == createTabTag {
                self.isShowingCreateSheet = true
                self.selectedTab = 0 // Reset selection to the first tab.
            }
        }
        .fullScreenCover(isPresented: $isShowingCreateSheet) {
            CreateEventView()
        }
    }
}

#Preview {
    let authManager = AuthManager()
    let locationManager = LocationManager()

    MainView()
        .environmentObject(authManager)
        .environmentObject(locationManager)
}

