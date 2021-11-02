//
//  Homebrew+ResponseModels.swift
//  barber
//
//  Created by Max Ainatchi on 5/20/21.
//  Copyright © 2021 Max Ainatchi, Inc. All rights reserved.
//

import Foundation

extension Homebrew {
    struct Response<Formulae: Codable, Cask: Codable>: Codable {
        let formulae: [Formulae]
        let casks: [Cask]
    }

    struct OutdatedEntry: Codable {
        let name: String
        let installedVersions: [String]
        let currentVersion: String
        let pinned: Bool
        let pinnedVersion: String?
    }

    struct OutdatedCaskEntry: Codable {
        let name: String
        let installedVersions: String
        let currentVersion: String
    }

    typealias OutdatedResponse = Response<OutdatedEntry, OutdatedCaskEntry>

    // Note: This entry is intentionally incomplete
    struct InfoEntry: Codable {
        struct Versions: Codable {
            let stable: String
            let head: String?
            let bottle: Bool
        }

        struct URLs: Codable {
            struct StableURLs: Codable {
                let url: URL
                let tag: URL?
                let revision: URL?
            }

            let stable: StableURLs
        }

        let name: String
        let fullName: String
        let tap: String
        let oldname: String?
        let aliases: [String]
        let versionedFormulae: [String]
        let desc: String
        let license: String?
        let homepage: URL
        let versions: Versions
        let urls: URLs
        let revision: Int
        let pinned: Bool
        let outdated: Bool
        let deprecated: Bool
        let deprecationDate: Date?
        let deprecationReason: String?
        let disabled: Bool
        let disableDate: Date?
        let disableReason: String?
    }

    typealias InfoResponse = Response<InfoEntry, InfoEntry>
}
