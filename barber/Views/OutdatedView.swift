//
//  OutdatedView.swift
//  barber
//
//  Created by Max Ainatchi on 5/16/21.
//  Copyright © 2021 Max Ainatchi, Inc. All rights reserved.
//

import SwiftUI

extension View {
    @ViewBuilder func hidden(if condition: Bool) -> some View {
        if condition {
            self.hidden()
        } else {
            self
        }
    }
}

extension CGFloat {
    static let defaultCornerRadius: CGFloat = 3.0
}

struct Code: View {
    let text: String

    var body: some View {
        Text(text).font(.system(.body, design: .monospaced))
            .cornerRadius(.defaultCornerRadius)
    }
}

struct OutdatedView: View {
    var entry: Homebrew.OutdatedEntry

    @State var collapsed = true
    @State var animationValue = 0
    @ObservedObject var infoState: LoadState<Homebrew.InfoResponse>
    @ObservedObject var updateState: LoadState<Void>

    init(entry: Homebrew.OutdatedEntry) {
        self.entry = entry
        self.infoState = LoadState(load: { try await Homebrew.shared.info(name: entry.name) })
        self.updateState = LoadState(load: { try await Homebrew.shared.update(name: entry.name) })
    }

    var body: some View {
        VStack {
            HStack {
                Image(systemName: "chevron.\(collapsed ? "up" : "down")")
                if entry.pinned {
                    Text("📌")
                }
                Code(text: entry.name)
                Text("\(entry.installedVersions.first ?? "") → \(entry.currentVersion)")
                Spacer()
                ActionButton(text: "Update", state: self.updateState, successView: { Text("✅") })
            }.onTapGesture {
                collapsed.toggle()
                if !collapsed {
                    animationValue += 1
                }
            }
            VStack {
                if !collapsed {
                    Divider()
                    InfoView(state: self.infoState).onAppear {
                        self.infoState.reload()
                    }
                }
            }
            .clipped().animation(.easeOut, value: collapsed).transition(.slide)
        }
        .cornerRadius(.defaultCornerRadius)
    }
}

struct OutdatedView_Previews: PreviewProvider {
    static var previews: some View {
        OutdatedView(entry: .init(name: "homebrew", installedVersions: ["1.6.13"], currentVersion: "1.6.14", pinned: false, pinnedVersion: nil))
    }
}
