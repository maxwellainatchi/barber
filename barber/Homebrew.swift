//
//  Homebrew.swift
//  barber
//
//  Created by Max Ainatchi on 5/16/21.
//  Copyright © 2021 Max Ainatchi, Inc. All rights reserved.
//

import Foundation
import ShellOut

private protocol HomebrewExecutor {
    func execute(command: String, arguments: [String]) throws -> Data
}

private class HomebrewJSONLoader: HomebrewExecutor {
    private let registeredFileNames: [String: String] = [
        "outdated": "brew-outdated.json",
    ]

    func execute(command: String, arguments _: [String]) -> Data {
        guard let name = self.registeredFileNames[command] else {
            fatalError("No registered file name for command \(command)")
        }
        let path = Bundle.main.resourceURL!
            .appendingPathComponent("mock-data")
            .appendingPathComponent(name)
        guard FileManager.default.fileExists(atPath: path.path) else {
            fatalError("File doesn't exist at path \(path.path)")
        }
        do {
            return try Data(contentsOf: path)
        } catch let err {
            fatalError("Failed to load file \(path.path) due to \(err)")
        }
    }
}

private class HomebrewCLIExecutor: HomebrewExecutor {
    func execute(command: String, arguments: [String]) throws -> Data {
        try shellOut(to: "/usr/local/bin/brew", arguments: [command] + arguments).data(using: .utf8)!
    }
}

class Homebrew {
    public static var shared = Homebrew(executor: HomebrewCLIExecutor())

    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

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

    struct OutdatedResponse: Codable {
        let formulae: [OutdatedEntry]
        let casks: [OutdatedCaskEntry]
    }

    private let executor: HomebrewExecutor

    private init(executor: HomebrewExecutor) {
        self.executor = executor
    }

    func outdated() throws -> OutdatedResponse {
        try self.execute(command: "outdated", "--json=v2", andLoadInto: OutdatedResponse.self)
    }

    private func execute<C: Decodable>(command: String, _ arguments: String..., andLoadInto decodable: C.Type) throws -> C {
        let data = try self.executor.execute(command: command, arguments: arguments)
        return try Self.decoder.decode(decodable, from: data)
    }
}

extension Homebrew.OutdatedEntry: Identifiable {
    var id: String {
        self.name
    }
}
