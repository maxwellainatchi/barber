//
//  ContentView.swift
//  barber
//
//  Created by Max Ainatchi on 7/18/20.
//  Copyright © 2020 Max Ainatchi, Inc. All rights reserved.
//

import SwiftUI
import Introspect

#if DEBUG
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
#endif

extension EdgeInsets {
    static func make(top: CGFloat = 0, leading: CGFloat = 0, bottom: CGFloat = 0, trailing: CGFloat = 0) -> EdgeInsets {
        .init(top: top, leading: leading, bottom: bottom, trailing: trailing)
    }
}

struct ContentView: View {
    var state: LoadState<Homebrew.OutdatedResponse>
    let size: NSSize
    
    #if DEBUG
    @State var colorScheme: ColorScheme = .dark
    #endif

    var body: some View {
        VStack {
            LoadModelView(state: self.state) { outdated in
                HStack {
                    if !outdated.formulae.isEmpty {
                        List(outdated.formulae) { entry in
                            OutdatedView(entry: entry)
                        }.backgroundColor(color: .clear)
                    } else {
                        TextWithLoadButton(text: "Up to date 🎉", reload: { self.state.reload(force: true) })
                    }
                }
            }
            Button("Quit") { exit(0) }.padding(.top, 10)
            #if DEBUG
            Button("Enable \(self.colorScheme.toggled().description) mode", action: {
                self.colorScheme = self.colorScheme.toggled()
            })
            #endif
        }
        .padding(.bottom)
        .frame(width: size.width, height: size.height)
        #if DEBUG
        .preferredColorScheme(self.colorScheme)
        #endif
    }
}
