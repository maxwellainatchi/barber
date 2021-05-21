//
//  LoadModelView.swift
//  barber
//
//  Created by Max Ainatchi on 5/20/21.
//  Copyright © 2021 Max Ainatchi, Inc. All rights reserved.
//

import Foundation
import SwiftUI

class LoadState<T, E: Error>: ObservableObject {
    enum Status {
        case unloaded
        case loading
        case loaded(T)
        case errored(E)
        
        var shouldReload: Bool {
            switch self {
            case .unloaded, .errored: return true
            case .loading, .loaded: return false
            }
        }
    }

    @Published var status: Status = .unloaded
    let load: (@escaping (Result<T, E>) -> Void) -> Void

    init(load: @escaping (@escaping (Result<T, E>) -> Void) -> Void) {
        self.load = load
    }
    
    convenience init(result load: @autoclosure @escaping () -> Result<T, E>) {
        self.init {
            $0(load())
        }
    }
    
    // NOTE: This is here so we can use `self.reload` by reference
    func reload() {
        self.reload(force: false)
    }

    func reload(force: Bool) {
        guard force || self.status.shouldReload else { return }
        self.status = .loading
        self.load { result in
            switch result {
            case let .success(model):
                self.status = .loaded(model)
            case let .failure(error):
                self.status = .errored(error)
            }
        }
    }
}

extension LoadState where E == Error {
    convenience init(value load: @autoclosure @escaping () throws -> T) {
        self.init {
            $0(Result { try load() })
        }
    }
}

struct LoadModelView<T, V: View, E: Error>: View {
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

    @ObservedObject var state: LoadState<T, E>
    let innerViewConstructor: (T) -> V

    init(state: LoadState<T, E>, innerViewConstructor: @escaping (T) -> V) {
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
