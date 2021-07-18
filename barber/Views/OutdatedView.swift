//
//  OutdatedView.swift
//  barber
//
//  Created by Max Ainatchi on 5/16/21.
//  Copyright © 2021 Max Ainatchi, Inc. All rights reserved.
//

import SwiftUI

extension Color {
    static let background = Color.white.opacity(0.2)
    static let deemphasizedBackground = Color.background.opacity(0.1)
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
    @ObservedObject var infoState: LoadState<Homebrew.InfoResponse, Error>

    init(entry: Homebrew.OutdatedEntry) {
        self.entry = entry
        self.infoState = LoadState(load: { Homebrew.shared.info(name: entry.name, callback: $0) })
    }

    var body: some View {
        VStack {
            HStack {
                Text(collapsed ? "▶︎" : "▼")
                Code(text: entry.name)
                Text("\(entry.installedVersions.first ?? "") → \(entry.currentVersion)")
                Spacer()
                if entry.pinned {
                    Text("📌")
                }
            }.onTapGesture {
                collapsed.toggle()
            }
            if !self.collapsed {
                InfoView(state: self.infoState).onAppear {
                    self.infoState.reload()
                }
            }
        }.animation(.interactiveSpring())
            .border(Color.deemphasizedBackground, width: 1)
            .cornerRadius(.defaultCornerRadius)
    }
}

struct OutdatedView_Previews: PreviewProvider {
    static var previews: some View {
        OutdatedView(entry: .init(name: "homebrew", installedVersions: ["1.6.13"], currentVersion: "1.6.14", pinned: false, pinnedVersion: nil))
    }
}
