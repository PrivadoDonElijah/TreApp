import SwiftUI
import MapKit

struct TreeMapView: View {
    @StateObject private var donationManager = DonationManager.shared
    @State private var selectedLocation: PlantedTreeLocation? = PlantedTreeLocation.philippinesLocations.first

    // Initial camera position centered over the Philippine Archipelago
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 12.8797, longitude: 121.7740),
            span: MKCoordinateSpan(latitudeDelta: 12.0, longitudeDelta: 10.0)
        )
    )

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // Interactive Map focused on the Philippines
                Map(position: $position) {
                    ForEach(PlantedTreeLocation.philippinesLocations) { location in
                        Annotation(location.regionName, coordinate: location.coordinate) {
                            Button {
                                selectedLocation = location
                            } label: {
                                VStack(spacing: 0) {
                                    Image(systemName: "tree.circle.fill")
                                        .resizable()
                                        .frame(width: 32, height: 32)
                                        .foregroundColor(.green)
                                        .background(Circle().fill(.white))
                                    
                                    Image(systemName: "triangle.fill")
                                        .resizable()
                                        .frame(width: 8, height: 6)
                                        .foregroundColor(.green)
                                        .rotationEffect(.degrees(180))
                                        .offset(y: -2)
                                }
                                .scaleEffect(selectedLocation?.id == location.id ? 1.25 : 1.0)
                                .animation(.spring(), value: selectedLocation?.id)
                            }
                        }
                    }
                }
                .mapStyle(.hybrid(elevation: .realistic))
                .ignoresSafeArea(edges: .bottom)

                // Selected Location Details Card
                if let location = selectedLocation {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(location.regionName)
                                    .font(.headline)
                                Text("\(location.country) • Partner: \(location.partnerName)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "leaf.fill")
                                .foregroundColor(.green)
                                .font(.title2)
                        }
                        
                        Divider()

                        HStack(spacing: 16) {
                            VStack(alignment: .leading) {
                                Text("Trees Planted")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(location.treesPlanted) 🌲")
                                    .font(.title3)
                                    .bold()
                            }

                            Spacer()

                            VStack(alignment: .leading) {
                                Text("Date Planted")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(location.datePlanted)
                                    .font(.title3)
                                    .bold()
                            }

                            Spacer()

                            VStack(alignment: .leading) {
                                Text("Coordinates")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(String(format: "%.2f", location.coordinate.latitude)), \(String(format: "%.2f", location.coordinate.longitude))")
                                    .font(.footnote)
                                    .bold()
                            }
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                    .padding()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .navigationTitle("Philippine Reforestation")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    TreeMapView()
}
