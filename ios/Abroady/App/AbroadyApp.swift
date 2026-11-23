import SwiftUI

@main
struct AbroadyApp: App {
    @State private var model = AppModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(model)
                .tint(Color.brand)
                .task { await model.bootstrap() }
        }
    }
}

struct RootView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        @Bindable var model = model
        TabView {
            ExploreView()
                .tabItem { Label("Explore", systemImage: "globe.americas.fill") }
            EventsView()
                .tabItem { Label("Events", systemImage: "calendar") }
            AmbassadorsView()
                .tabItem { Label("Ambassadors", systemImage: "person.2.badge.gearshape.fill") }
            ChecklistView()
                .tabItem { Label("Checklist", systemImage: "checklist") }
            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.crop.circle") }
        }
        .errorAlert($model.errorMessage)
    }
}
