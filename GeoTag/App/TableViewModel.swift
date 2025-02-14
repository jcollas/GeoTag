//
// Copyright 2023 Marco S Hyman
// See LICENSE file for info
// https://www.snafu.org/
//

import OSLog
import SwiftUI

// MARK: State variables used primarily to control the table of images

@MainActor
@Observable
final class TableViewModel {
    var images: [ImageModel] = []
    var searchImages: [ImageModel] = []
    var selection: Set<ImageModel.ID> = [] {
        didSet {
            selectionChanged()
        }
    }
    var selected: [ImageModel] = []
    var mostSelected: ImageModel?

    // get an image from the table of images  given its ID.
    // No setter is defined
    subscript(id: ImageModel.ID?) -> ImageModel {
        if let index = images.firstIndex(where: { $0.id == id }) {
            Self.logger.notice(
                "get \(self.images[index].name, privacy: .public)")
            return images[index]
        }

        // A view may hold on to an ID that is no longer in the table
        // If it tries to access the image associated with that id
        // return a fake image
        return ImageModel()
    }

    // A copy of the current sort order
    var sortOrder = [KeyPathComparator(\ImageModel.name)]

    init() {
        Self.logger.notice("TableViewModel created")
    }

    // init for preview

    init(images: [ImageModel]) {
        self.images.append(contentsOf: images)
    }
}

// search related functions

extension TableViewModel {
    func search(for match: String) {
        Self.logger.notice("Searching for \(match, privacy: .public)")
        searchImages = images.filter { $0.isValid && $0.name.fuzzy(match) }
        Self.logger.notice("Matched \(self.searchImages.count) images")
    }

    func clearSearch() {
        Self.logger.notice("Clearing search")
        searchImages = []
    }
}

extension TableViewModel {

    private static let logger = Logger(
        subsystem: "org.snafu.GeoTag",
        category: "TableView")
    private static let signposter = OSSignposter(logger: logger)

    func markStart(_ desc: StaticString) -> OSSignpostIntervalState {
        let signpostID = Self.signposter.makeSignpostID()
        let interval = Self.signposter.beginInterval(desc, id: signpostID)
        return interval
    }

    func markEnd(_ desc: StaticString, interval: OSSignpostIntervalState) {
        Self.signposter.endInterval(desc, interval)
    }

    func withInterval<T>(
        _ desc: StaticString,
        around task: () throws -> T
    ) rethrows -> T {
        try Self.signposter.withIntervalSignpost(desc) {
            try task()
        }
    }
    func withInterval<T>(
        _ image: ImageModel,
        around task: () throws -> T
    ) rethrows -> T {
        try Self.signposter.withIntervalSignpost(
            "Render", "image \(image.name)"
        ) {
            try task()
        }
    }

}

// a simple, fast enough search. Return true if the string characters match
// "pattern" characters in the given order ignoring case.

extension String {
    func fuzzy(_ pattern: String) -> Bool {
        // an empty pattern matches anything
        guard !pattern.isEmpty else { return true }
        var remainder = pattern[...]
        for char in self
        where char.lowercased() == remainder[remainder.startIndex].lowercased() {
            remainder.removeFirst()
            if remainder.isEmpty { return true }
        }
        return false
    }
}
