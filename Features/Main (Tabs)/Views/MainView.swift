import SwiftUI

struct MainView: View {
    // Состояния для таб-бара
    @State private var selectedTab = 0
    @State private var isShowingCreateSheet = false
    private let createTabTag = 1
    
    // СОЗДАЕМ VIEWMODEL ЗДЕСЬ
    @StateObject private var eventsViewModel = EventsViewModel()

    var body: some View {
        TabView(selection: $selectedTab) {
            MapView()
                .tabItem { Label("Карта", systemImage: "map") }
                .tag(0)

            Color.clear
                .tabItem { Label("Создать", systemImage: "plus.circle.fill") }
                .tag(createTabTag)
            
            MyEventsView()
                .tabItem { Label("Мои", systemImage: "calendar") }
                .tag(2)

            ProfileView()
                .tabItem { Label("Профиль", systemImage: "person.crop.circle") }
                .tag(3)
        }
        // ВНЕДРЯЕМ VIEWMODEL В ОКРУЖЕНИЕ
        // Теперь он доступен всем вкладкам
        .environmentObject(eventsViewModel)
        .onChange(of: selectedTab) { _, newTab in
            if newTab == createTabTag {
                self.isShowingCreateSheet = true
                self.selectedTab = 0
            }
        }
        .fullScreenCover(isPresented: $isShowingCreateSheet) {
            CreateEventView()
        }
    }
}
