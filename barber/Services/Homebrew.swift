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

private class HomebrewMockExecutor: HomebrewExecutor {
    fileprivate let realExecutor = HomebrewCLIExecutor()

    private enum Action: String {
        case outdated, info, upgrade

        func execute(_ executor: HomebrewMockExecutor, arguments: [String]) throws -> Data {
            switch self {
            case .outdated:
                return executor.readFile(name: "brew-outdated.json")
            case .info:
                return executor.readFile(name: "brew-info-cairo.json")
            case .upgrade:
                let result = try executor.realExecutor.execute(command: self.rawValue, arguments: arguments)
                print("upgrade \(arguments.joined(separator: " ")) result: \(String(data: result, encoding: .utf8) ?? "none")")
                return result
            }
        }
    }

    func execute(command: String, arguments: [String]) throws -> Data {
        guard let action = Action(rawValue: command) else {
            preconditionFailure("unknown command")
        }
        return try action.execute(self, arguments: arguments)
    }

    fileprivate func readFile(name: String) -> Data {
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
    public static var shared = Homebrew(executor: HomebrewCLIExecutor())

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

    func update(name: String? = nil) async throws {
        let result = try self.executor.execute(command: "upgrade", arguments: [name ?? "", "--dry-run"])
        print(String(data: result, encoding: .utf8) ?? "")
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
