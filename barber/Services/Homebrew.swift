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

func isAppleSilicon() -> Bool {
    var systeminfo = utsname()
    uname(&systeminfo)
    let machine = withUnsafeBytes(of: &systeminfo.machine) { bufPtr -> String? in
        let data = Data(bufPtr)
        if let lastIndex = data.lastIndex(where: { $0 != 0 }) {
            return String(data: data[0 ... lastIndex], encoding: .isoLatin1)
        } else {
            return String(data: data, encoding: .isoLatin1)
        }
    }
    return machine == "arm64"
}

private class HomebrewCLIExecutor: HomebrewExecutor {
    private static func findHomebrew() -> String {
        isAppleSilicon() ? "/opt/homebrew/bin/brew" : "/usr/local/bin/brew"
    }

    private let homebrewPath: String

    init() {
        self.homebrewPath = Self.findHomebrew()
    }

    func execute(command: String, arguments: [String]) throws -> Data {
        try shellOut(to: self.homebrewPath, arguments: [command] + arguments).data(using: .utf8)!
    }
}

actor Homebrew {
    private static let queue = DispatchQueue(label: "Homebrew", attributes: .concurrent)
    public static var shared = Homebrew(executor: HomebrewJSONLoader())

    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    private let executor: HomebrewExecutor

    private init(executor: HomebrewExecutor) {
        self.executor = executor
    }

    func outdated() async throws -> OutdatedResponse {
        try self.execute(command: "outdated", "--json=v2", andLoadInto: OutdatedResponse.self)
    }

    func info(name: String) async throws -> InfoResponse {
        try self.execute(command: "info", name, "--json=v2", andLoadInto: InfoResponse.self)
    }

    private func execute<C: Decodable>(command: String, _ arguments: String..., andLoadInto decodable: C.Type) throws -> C {
        do {
            let data = try self.executor.execute(command: command, arguments: arguments)
            return try Self.decoder.decode(decodable, from: data)
        } catch {
            print("Error executing:", error)
            throw error
        }
    }
}

extension Homebrew.OutdatedEntry: Identifiable {
    var id: String {
        self.name
    }
}
