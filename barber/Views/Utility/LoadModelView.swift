//
//  LoadModelView.swift
//  barber
//
//  Created by Max Ainatchi on 5/20/21.
//  Copyright © 2021 Max Ainatchi, Inc. All rights reserved.
//

import Foundation
import SwiftUI

struct ActionButton<T, V: View>: View {
    let text: String
    @ObservedObject var state: LoadState<T>
    let successView: (T) -> V

    var body: some View {
        HStack {
            if case let .loaded(value) = self.state.status {
                self.successView(value)
            } else {
                switch self.state.status {
                case .unloaded: Text("")
                case .loading: ProgressView().progressViewStyle(.circular).tint(.blue).scaleEffect(0.5)
                case let .errored(error): Text("❌")
                case .loaded: fatalError()
                }
                Button(self.text, action: self.state.reload)
            }
        }
    }
}
