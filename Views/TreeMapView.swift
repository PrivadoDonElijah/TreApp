
import SwiftUI
import MapKit

struct TreeMapView: View {

    // MARK: - State

    @StateObject private var donationManager = DonationManager.shared

    @State private var selectedLocation: PlantedTreeLocation? =
        PlantedTreeLocation.philippinesLocations.first

    @State private var showReservePhoto = false

    // MARK: - Map Camera

    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: 12.8797,
                longitude: 121.7740
            ),
            span: MKCoordinateSpan(
                latitudeDelta: 12.0,
                longitudeDelta: 10.0
            )
        )
    )

    // MARK: - Main View

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {

                // Interactive Philippine Map
                Map(position: $position) {
                    ForEach(
                        PlantedTreeLocation.philippinesLocations
                    ) { location in

                        Annotation(
                            location.regionName,
                            coordinate: location.coordinate
                        ) {
                            Button {
                                withAnimation(.spring()) {
                                    selectedLocation = location
                                }
                                showReservePhoto = true

                            } label: {
                                marker(for: location)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .mapStyle(.hybrid(elevation: .realistic))
                .ignoresSafeArea(edges: .bottom)

                // Selected Reserve Details
                if let location = selectedLocation {
                    reserveDetails(location)
                        .transition(
                            .move(edge: .bottom)
                            .combined(with: .opacity)
                        )
                }
            }
            .navigationTitle("Philippine Reforestation")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showReservePhoto) {
                if let location = selectedLocation {
                    reservePhotoSheet(location)
                }
            }
        }
    }

    // MARK: - Tree Marker

    private func marker(
        for location: PlantedTreeLocation
    ) -> some View {

        VStack(spacing: 0) {

            Image(systemName: "tree.circle.fill")
                .resizable()
                .frame(width: 32, height: 32)
                .foregroundStyle(.green)
                .background(
                    Circle().fill(.white)
                )

            Image(systemName: "triangle.fill")
                .resizable()
                .frame(width: 8, height: 6)
                .foregroundStyle(.green)
                .rotationEffect(.degrees(180))
                .offset(y: -2)
        }
        .scaleEffect(
            selectedLocation?.id == location.id
            ? 1.25 : 1.0
        )
        .animation(
            .spring(),
            value: selectedLocation?.id
        )
    }

    // MARK: - Reserve Details Card

    private func reserveDetails(
        _ location: PlantedTreeLocation
    ) -> some View {

        VStack(alignment: .leading, spacing: 12) {

            HStack {
                VStack(alignment: .leading, spacing: 4) {

                    Text(location.regionName)
                        .font(.headline)

                    Text(
                        "\(location.country) • Partner: \(location.partnerName)"
                    )
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "leaf.fill")
                    .foregroundStyle(.green)
                    .font(.title2)
            }

            Divider()

            HStack(spacing: 16) {

                VStack(alignment: .leading) {
                    Text("Trees Planted")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("\(location.treesPlanted) 🌲")
                        .font(.title3.bold())
                }

                Spacer()

                VStack(alignment: .leading) {
                    Text("Date Planted")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(location.datePlanted)
                        .font(.title3.bold())
                }

                Spacer()

                VStack(alignment: .leading) {
                    Text("Coordinates")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(
                        String(
                            format: "%.2f, %.2f",
                            location.coordinate.latitude,
                            location.coordinate.longitude
                        )
                    )
                    .font(.footnote.bold())
                }
            }

            Button {
                showReservePhoto = true
            } label: {
                Label(
                    "View Reserve Photo",
                    systemImage: "photo.fill"
                )
                .font(.subheadline.bold())
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(12)
                .background(.green)
                .clipShape(
                    RoundedRectangle(cornerRadius: 12)
                )
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(
            RoundedRectangle(cornerRadius: 16)
        )
        .padding()
    }

    // MARK: - Reserve Photo Sheet

    private func reservePhotoSheet(
        _ location: PlantedTreeLocation
    ) -> some View {

        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    reserveImage(for: location)

                    Text(location.regionName)
                        .font(.title2.bold())

                    Label(
                        "Philippine Reforestation Site",
                        systemImage: "leaf.fill"
                    )
                    .foregroundStyle(.green)

                    Text(
                        "Partner: \(location.partnerName)"
                    )
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                    Divider()

                    HStack {
                        Label(
                            "\(location.treesPlanted) Trees",
                            systemImage: "tree.fill"
                        )

                        Spacer()

                        Text(location.datePlanted)
                    }
                    .font(.subheadline)

                    Text(
                        "Location: \(location.country)"
                    )
                    .foregroundStyle(.secondary)
                }
                .padding()
            }
            .navigationTitle("Reserve Photo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        showReservePhoto = false
                    }
                }
            }
        }
    }

    // MARK: - Reserve Image

    private func reserveImage(
        for location: PlantedTreeLocation
    ) -> some View {

        let imageName = reserveImageName(
            for: location.regionName
        )

        return Image(imageName)
            .resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity)
            .frame(height: 260)
            .clipped()
            .clipShape(
                RoundedRectangle(cornerRadius: 18)
            )
    }

    // MARK: - Image Asset Mapping

    private func reserveImageName(
        for regionName: String
    ) -> String {

        let name = regionName.lowercased()

        if name.contains("calabarzon") {
            return "calabarzon_forest"
        }

        if name.contains("cebu") {
            return "cebu_forest"
        }

        if name.contains("mindanao") {
            return "mindanao_forest"
        }

        if name.contains("luzon") {
            return "luzon_forest"
        }

        return "default_forest"
    }
}

// MARK: - Preview

#Preview {
    TreeMapView()
}
