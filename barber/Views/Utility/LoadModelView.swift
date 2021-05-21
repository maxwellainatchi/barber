//
//  LoadModelView.swift
//  barber
//
//  Created by Max Ainatchi on 5/20/21.
//  Copyright © 2021 Max Ainatchi, Inc. All rights reserved.
//

import Foundation
import SwiftUI

enum LoadState<T, E: Error> {
    case unloaded
    case loading
    case loaded(T)
    case errored(E)
}

protocol Reloadable: View {
    func reload()
}

struct LoadModelView<T, V: View, E: Error>: View, Reloadable {
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

    @State var state: LoadState<T, E> = .unloaded
    let innerViewConstructor: (T) -> V
    let load: (_ callback: (Result<T, E>) -> Void) -> Void

    init(load: @escaping (_ callback: (Result<T, E>) -> Void) -> Void, innerViewConstructor: @escaping (T) -> V) {
        self.innerViewConstructor = innerViewConstructor
        self.load = load
    }

    var body: some View {
        HStack {
            switch self.state {
            case .unloaded:
                TextWithLoadButton(text: "Not yet loaded", reload: reload)
            case .loading:
                ProgressView()
            case let .loaded(model):
                self.innerViewConstructor(model)
            case let .errored(error):
                TextWithLoadButton(text: "Error: \(error.localizedDescription)", reload: reload)
            }
        }
    }

    func reload() {
        self.state = .loading
        self.load { result in
            switch result {
            case let .success(model):
                self.state = .loaded(model)
            case let .failure(error):
                self.state = .errored(error)
            }
        }
    }
}
