//
//  Homebrew.swift
//  barber
//
//  Created by Max Ainatchi on 5/16/21.
//  Copyright © 2021 Max Ainatchi, Inc. All rights reserved.
//

import Foundation

fileprivate protocol HomebrewExecutor {
    func execute(command: String, arguments: [String]) -> Data
}

fileprivate class HomebrewJSONLoader: HomebrewExecutor {
    private let registeredFileNames: [String: String] = [
        "outdated": "brew-outdated.json"
    ]
    
    func execute(command: String, arguments: [String]) -> Data {
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

class Homebrew {
    public static var shared = Homebrew(executor: HomebrewJSONLoader())
    
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
    
    struct OutdatedResponse: Codable {
        let formulae: [OutdatedEntry]
        let casks: [OutdatedEntry]
    }
    
    private let executor: HomebrewExecutor
    
    private init(executor: HomebrewExecutor) {
        self.executor = executor
    }
    
    func outdated() -> OutdatedResponse {
        // TODO: error handling
        try! self.execute(command: "outdated", "--json=v2", andLoadInto: OutdatedResponse.self)
    }
    
    private func execute<C: Decodable>(command: String, _ arguments: String..., andLoadInto decodable: C.Type) throws -> C {
        let data = self.executor.execute(command: command, arguments: arguments)
        return try Self.decoder.decode(decodable, from: data)
    }
}

extension Homebrew.OutdatedEntry: Identifiable {
    var id: String {
        self.name
    }
}
