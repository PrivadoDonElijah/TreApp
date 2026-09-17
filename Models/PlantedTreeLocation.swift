import Foundation
import CoreLocation

struct PlantedTreeLocation: Identifiable {
    let id = UUID()
    let regionName: String
    let country: String
    let coordinate: CLLocationCoordinate2D
    let treesPlanted: Int
    let datePlanted: String
    let partnerName: String
    
    // Sample locations strictly inside the Philippines
    static let philippinesLocations: [PlantedTreeLocation] = [
        PlantedTreeLocation(
            regionName: "Calabarzon Watershed Reserve",
            country: "Philippines",
            coordinate: CLLocationCoordinate2D(latitude: 14.1000, longitude: 121.5000),
            treesPlanted: 30,
            datePlanted: "Sep 2026",
            partnerName: "DENR Calabarzon"
        ),
        PlantedTreeLocation(
            regionName: "Sierra Madre Mountain Range",
            country: "Philippines",
            coordinate: CLLocationCoordinate2D(latitude: 15.3000, longitude: 121.3500),
            treesPlanted: 50,
            datePlanted: "Aug 2026",
            partnerName: "Haribon Foundation"
        ),
        PlantedTreeLocation(
            regionName: "Mindanao Forest Corridor",
            country: "Philippines",
            coordinate: CLLocationCoordinate2D(latitude: 8.4542, longitude: 124.6319),
            treesPlanted: 25,
            datePlanted: "Jul 2026",
            partnerName: "Forest Foundation PH"
        ),
        PlantedTreeLocation(
            regionName: "Cebu Hillylands Reforestation",
            country: "Philippines",
            coordinate: CLLocationCoordinate2D(latitude: 10.3800, longitude: 123.8300),
            treesPlanted: 15,
            datePlanted: "Jun 2026",
            partnerName: "PBSP Visayas"
        )
    ]
}

