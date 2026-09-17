import SwiftUI

struct MainTabView: View {
    @Binding var isLoggedIn: Bool

    var body: some View {
        TabView {
            ExploreView()
                .tabItem {
                    Label("Explore", systemImage: "globe")
                }

            DonationView()
                .tabItem {
                    Label("Donate", systemImage: "leaf.arrow.circlepath")
                }

            VirtualForestView()
                .tabItem {
                    Label("3D Grove", systemImage: "tree.fill")
                }

            TreeMapView()
                .tabItem {
                    Label("Map", systemImage: "map.fill")
                }

            ImpactView()
                .tabItem {
                    Label("Impact", systemImage: "chart.bar.fill")
                }

            ProfileView(isLoggedIn: $isLoggedIn)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
        .tint(.green)
    }
}

#Preview {
    MainTabView(isLoggedIn: .constant(true))
}
