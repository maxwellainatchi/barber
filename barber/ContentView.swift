//
//  ContentView.swift
//  barber
//
//  Created by Max Ainatchi on 7/18/20.
//  Copyright © 2020 Max Ainatchi, Inc. All rights reserved.
//

import Introspect
import SwiftUI

extension ColorScheme {
    func toggled() -> ColorScheme {
        switch self {
        case .light:
            return .dark
        case .dark:
            return .light
        @unknown default: fatalError()
        }
    }
}

extension ColorScheme: CustomStringConvertible {
    public var description: String {
        switch self {
        case .dark: return "dark"
        case .light: return "light"
        @unknown default: return "unknown"
        }
    }
}

public extension Button where Label == Image {
    static func from(systemImageName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImageName)
        }.buttonStyle(.plain)
    }
}

extension EdgeInsets {
    static func make(top: CGFloat = 0, leading: CGFloat = 0, bottom: CGFloat = 0, trailing: CGFloat = 0) -> EdgeInsets {
        .init(top: top, leading: leading, bottom: bottom, trailing: trailing)
    }
}

import Combine

struct ContentView: View {
    @ObservedObject var state: LoadState<Homebrew.OutdatedResponse>
    let size: NSSize

    @ObservedObject var updateState: LoadState<Void>
    var sink: AnyCancellable?

    init(state: LoadState<Homebrew.OutdatedResponse>, size: NSSize) {
        self.state = state
        self.size = size
        let updateState = LoadState {
            try await Homebrew.shared.update()
        }
        self.updateState = updateState
        self.sink = self.updateState.$status.sink { status in
            if case .loaded = status {
                updateState.status = .unloaded
                state.reload(force: true)
            }
        }
    }

    @State var colorScheme: ColorScheme = .dark

    var body: some View {
        VStack(spacing: 10) {
            Text("Homebrew").font(.largeTitle).padding(.horizontal)
            Spacer()
            LoadModelView(state: self.state) { outdated in
                HStack {
                    if !outdated.formulae.isEmpty {
                        List(outdated.formulae) { entry in
                            OutdatedView(entry: entry)
                        }.backgroundColor(color: .clear)
                    } else {
                        Text("Up to date 🎉")
                    }
                }
            }
            Spacer()
            Divider()
            HStack {
                Button.from(systemImageName: "xmark.circle", action: { exit(0) }).help("Quit")
                Button.from(systemImageName: "arrow.clockwise", action: { self.state.reload(force: true) }).help("Reload")
                Button.from(systemImageName: self.colorScheme == .dark ? "sun.max.circle.fill" : "moon.circle", action: {
                    self.colorScheme = self.colorScheme.toggled()
                }).help("Enable \(self.colorScheme.toggled().description) mode")
                Spacer()
                if case .loaded = self.state.status {
                    ActionButton(text: "Update all", state: self.updateState, successView: { Text("✅") })
                        .buttonStyle(.borderedProminent)
                }
            }.padding(.horizontal)
        }
        .padding(.vertical)
        .frame(width: size.width, height: size.height)
        #if DEBUG
            .preferredColorScheme(self.colorScheme)
        #endif
    }
}
