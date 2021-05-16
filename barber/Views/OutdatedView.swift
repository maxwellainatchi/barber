//
//  OutdatedView.swift
//  barber
//
//  Created by Max Ainatchi on 5/16/21.
//  Copyright © 2021 Max Ainatchi, Inc. All rights reserved.
//

import SwiftUI

extension Color {
    static let deemphasizedBackground = Color(.sRGB, white: 1, opacity: 0.1)
}

extension CGFloat {
    static let defaultCornerRadius: CGFloat = 3.0
}

struct Code: View {
    let text: String
    
    var body: some View {
        Text(text).font(.system(.body, design: .monospaced))
            .background(Color.deemphasizedBackground)
            .cornerRadius(.defaultCornerRadius)
    }
}

struct OutdatedView: View {
    var entry: Homebrew.OutdatedEntry
    
    @State var collapsed = true
    
    var body: some View {
        HStack {
            Text(collapsed ? "▶︎" : "▼")
            Code(text: entry.name)
            Text("\(entry.installedVersions.first ?? "") → \(entry.currentVersion)")
            Spacer()
        }.onTapGesture {
            collapsed.toggle()
        }.padding(.all, 5).border(Color.deemphasizedBackground, width: 1).cornerRadius(.defaultCornerRadius)
    }
}

struct OutdatedView_Previews: PreviewProvider {
    static var previews: some View {
        OutdatedView(entry: .init(name: "homebrew", installedVersions: ["1.6.13"], currentVersion: "1.6.14", pinned: false, pinnedVersion: nil))
    }
}
