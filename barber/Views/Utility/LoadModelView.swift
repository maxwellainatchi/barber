//
//  LoadModelView.swift
//  barber
//
//  Created by Max Ainatchi on 5/20/21.
//  Copyright © 2021 Max Ainatchi, Inc. All rights reserved.
//

import Foundation
import SwiftUI

class LoadState<T>: ObservableObject {
    enum Status {
        case unloaded
        case loading
        case loaded(T)
        case errored(Error)

        var shouldReload: Bool {
            switch self {
            case .unloaded, .errored: return true
            case .loading, .loaded: return false
            }
        }
    }

    @Published var status: Status = .unloaded
    let load: () async throws -> T

    init(load: @escaping (() async throws -> T)) {
        self.load = load
    }

    // NOTE: This is here so we can use `self.reload` by reference
    func reload() {
        self.reload(force: false)
    }

    func reload(force: Bool) {
        Task {
            await self.reloadAsync(force: force)
        }
    }

    @MainActor
    func reloadAsync(force: Bool) async {
        guard force || self.status.shouldReload else { return }
        self.status = .loading
        do {
            self.status = .loaded(try await self.load())
        } catch {
            self.status = .errored(error)
        }
    }
}

struct TextWithLoadButton: View {
    let text: String
    let reload: () -> Void
    var body: some View {
        VStack {
            Text(text)
            Button("Reload", action: reload)
        }
    }
}

struct LoadModelView<T, V: View>: View {
    @ObservedObject var state: LoadState<T>
    let innerViewConstructor: (T) -> V

    init(state: LoadState<T>, innerViewConstructor: @escaping (T) -> V) {
        self.innerViewConstructor = innerViewConstructor
        self.state = state
    }

    var body: some View {
        HStack {
            switch self.state.status {
            case .unloaded:
                TextWithLoadButton(text: "Not yet loaded", reload: self.state.reload)
            case .loading:
                ProgressView()
            case let .loaded(model):
                self.innerViewConstructor(model)
            case let .errored(error):
                TextWithLoadButton(text: "Error: \(error.localizedDescription)", reload: self.state.reload)
            }
        }
    }
}
