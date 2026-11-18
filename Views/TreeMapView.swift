
import SwiftUI
import MapKit
import UIKit

struct TreeMapView: View {

    // MARK: - Properties

    @StateObject private var donationManager = DonationManager.shared

    @State private var selectedLocation: PlantedTreeLocation? =
        PlantedTreeLocation.philippinesLocations.first

    @State private var photoLocation: PlantedTreeLocation?

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

                // Interactive Philippine map
                Map(position: $position) {
                    ForEach(PlantedTreeLocation.philippinesLocations) { location in
                        Annotation(
                            location.regionName,
                            coordinate: location.coordinate
                        ) {
                            Button {
                                selectReserve(location)
                            } label: {
                                treeMarker(for: location)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .mapStyle(.hybrid(elevation: .realistic))
                .ignoresSafeArea(edges: .bottom)

                // Selected reserve card
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
            .sheet(item: $photoLocation) { location in
                reservePhotoSheet(location)
            }
        }
    }

    // MARK: - Reserve Selection

    private func selectReserve(_ location: PlantedTreeLocation) {
        withAnimation(.spring()) {
            selectedLocation = location
        }

        photoLocation = location
    }

    // MARK: - Tree Marker

    private func treeMarker(
        for location: PlantedTreeLocation
    ) -> some View {
        VStack(spacing: 0) {
            Image(systemName: "tree.circle.fill")
                .resizable()
                .frame(width: 32, height: 32)
                .foregroundStyle(.green)
                .background(Circle().fill(.white))

            Image(systemName: "triangle.fill")
                .resizable()
                .frame(width: 8, height: 6)
                .foregroundStyle(.green)
                .rotationEffect(.degrees(180))
                .offset(y: -2)
        }
        .scaleEffect(
            selectedLocation?.id == location.id ? 1.25 : 1.0
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
        VStack(alignment: .leading, spacing: 14) {

            // Reserve heading
            HStack(alignment: .top, spacing: 10) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(location.regionName)
                        .font(.headline)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("\(location.country) • Partner: \(location.partnerName)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 4)

                Image(systemName: "leaf.fill")
                    .font(.title2)
                    .foregroundStyle(.green)
            }

            Divider()

            // Reserve statistics
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .top, spacing: 12) {
                    reserveStat(
                        title: "Trees Planted",
                        value: "\(location.treesPlanted) 🌲"
                    )

                    Spacer(minLength: 4)

                    reserveStat(
                        title: "Date Planted",
                        value: location.datePlanted
                    )

                    Spacer(minLength: 4)

                    reserveStat(
                        title: "Coordinates",
                        value: coordinates(for: location)
                    )
                }

                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top, spacing: 12) {
                        reserveStat(
                            title: "Trees Planted",
                            value: "\(location.treesPlanted) 🌲"
                        )

                        Spacer()

                        reserveStat(
                            title: "Date Planted",
                            value: location.datePlanted
                        )
                    }

                    reserveStat(
                        title: "Coordinates",
                        value: coordinates(for: location)
                    )
                }
            }

            // Open photo
            Button {
                photoLocation = location
            } label: {
                Label(
                    "View Reserve Photo",
                    systemImage: "photo.fill"
                )
                .font(.subheadline.bold())
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(13)
                .background(.green)
                .clipShape(
                    RoundedRectangle(cornerRadius: 12)
                )
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .clipShape(
            RoundedRectangle(cornerRadius: 18)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
    }

    // MARK: - Statistic Component

    private func reserveStat(
        title: String,
        value: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.subheadline.bold())
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Reserve Photo Sheet

    private func reservePhotoSheet(
        _ location: PlantedTreeLocation
    ) -> some View {
        NavigationStack {
            GeometryReader { geometry in
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {

                        // Forest image
                        reserveImage(for: location)

                        // Forest name
                        Text(location.regionName)
                            .font(.title2.bold())
                            .fixedSize(
                                horizontal: false,
                                vertical: true
                            )

                        // Reforestation label
                        Label(
                            "Philippine Reforestation Site",
                            systemImage: "leaf.fill"
                        )
                        .font(.subheadline)
                        .foregroundStyle(.green)

                        // Partner
                        Text("Partner: \(location.partnerName)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .fixedSize(
                                horizontal: false,
                                vertical: true
                            )

                        Divider()

                        // Planting information
                        HStack(alignment: .top, spacing: 16) {

                            VStack(alignment: .leading, spacing: 6) {
                                Text("Trees Planted")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                Label(
                                    "\(location.treesPlanted) Trees",
                                    systemImage: "tree.fill"
                                )
                                .font(.subheadline.bold())
                            }
                            .frame(
                                maxWidth: .infinity,
                                alignment: .leading
                            )

                            VStack(alignment: .leading, spacing: 6) {
                                Text("Date Planted")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                Text(location.datePlanted)
                                    .font(.subheadline.bold())
                                    .fixedSize(
                                        horizontal: false,
                                        vertical: true
                                    )
                            }
                            .frame(
                                maxWidth: .infinity,
                                alignment: .leading
                            )
                        }

                        Divider()

                        // Location
                        Label(
                            "Location: \(location.country)",
                            systemImage: "mappin.circle.fill"
                        )
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                        Text("Coordinates: \(coordinates(for: location))")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Divider()

                        // Conservation information
                        Label(
                            "Forest Conservation",
                            systemImage: "leaf.circle.fill"
                        )
                        .font(.headline)
                        .foregroundStyle(.green)

                        Text(
                            "This reserve is part of the Philippine reforestation monitoring initiative. The application displays the reserve location, planting information, and conservation records."
                        )
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(
                            horizontal: false,
                            vertical: true
                        )
                    }
                    .frame(
                        width: max(0, geometry.size.width - 32),
                        alignment: .leading
                    )
                    .padding(16)
                }
                .frame(width: geometry.size.width)
            }
            .navigationTitle("Reserve Photo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        photoLocation = nil
                    }
                    .foregroundStyle(.green)
                }
            }
        }
    }

    // MARK: - Forest Image

    private func reserveImage(
        for location: PlantedTreeLocation
    ) -> some View {
        let imageName = reserveImageName(
            for: location.regionName
        )

        return GeometryReader { geometry in
            Group {
                if let image = UIImage(named: imageName) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(
                            width: geometry.size.width,
                            height: 260
                        )
                        .clipped()
                } else {
                    missingImagePlaceholder(imageName)
                        .frame(
                            width: geometry.size.width,
                            height: 260
                        )
                }
            }
            .clipShape(
                RoundedRectangle(cornerRadius: 16)
            )
        }
        .frame(height: 260)
    }

    // MARK: - Missing Image Placeholder

    private func missingImagePlaceholder(
        _ imageName: String
    ) -> some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.green.opacity(0.7),
                    Color.green.opacity(0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 12) {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 42))

                Text("Reserve Photo Unavailable")
                    .font(.headline)

                Text("Missing asset: \(imageName)")
                    .font(.caption)
                    .multilineTextAlignment(.center)
            }
            .foregroundStyle(.white)
            .padding()
        }
    }

    // MARK: - Image Asset Mapping

    private func reserveImageName(
        for regionName: String
    ) -> String {
        let name = regionName.lowercased()

        if name.contains("sierra madre") {
            return "sierra_madre_forest"
        }

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

    // MARK: - Coordinate Formatter

    private func coordinates(
        for location: PlantedTreeLocation
    ) -> String {
        String(
            format: "%.2f, %.2f",
            location.coordinate.latitude,
            location.coordinate.longitude
        )
    }
}

// MARK: - Preview

#Preview {
    TreeMapView()
}
