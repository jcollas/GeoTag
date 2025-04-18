//
// Copyright 2023 Marco S Hyman
// See LICENSE file for info
// https://www.snafu.org/
//

import Foundation

// The representation of location and optionally elevation as a string.
// This value is used for copy and paste.
// Format: "latitude, longitude, elevation"
// latitude and longitude are formatted per GeoTag settings

extension ImageModel {
    var stringRepresentation: String {
        var stringRep = ""
        if location != nil {
            stringRep = "\(formattedLatitude), \(formattedLongitude)"
            if let elevation {
                stringRep += ", \(elevation)"
            }
        }
        return stringRep
    }

    // decode the above string representation into a tuple containing
    // coordinates and optional elevation.

    static func decodeStringRep(value: String) -> (Coords, Double?)? {
        // accept "| " as a separator for backwards compatibility
        let separator = /[,|]\s+/
        let components = value.split(separator: separator)
        if components.count == 2 || components.count == 3 {
            var coords: Coords

            if let latitude = String(components[0]).validateLatitude(),
                let longitude = String(components[1]).validateLongitude()
            {
                coords = Coords(latitude: latitude, longitude: longitude)
                if components.count == 3 {
                    let eleVal = components[2].trimmingCharacters(
                        in: .whitespaces)
                    if let elevation = Double(eleVal) {
                        return (coords, elevation)
                    }
                } else {
                    return (coords, nil)
                }
            }
        }
        return nil
    }
}
