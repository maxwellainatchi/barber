//
//  ContentView.swift
//  barber
//
//  Created by Max Ainatchi on 7/18/20.
//  Copyright © 2020 Max Ainatchi, Inc. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var state: LoadState<Homebrew.OutdatedResponse, Error>
    let size: NSSize

    var body: some View {
        VStack {
            LoadModelView(state: self.state) { outdated in
                HStack {
                    if !outdated.formulae.isEmpty {
                        List(outdated.formulae) { entry in
                            OutdatedView(entry: entry)
                        }
                    } else {
                        LoadModelView<Homebrew.OutdatedResponse, ContentView, Error>.TextWithLoadButton(text: "Up to date 🎉", reload: self.state.reload)
                    }
                }
            }
            Button("Quit") { exit(0) }.padding(.top, 10)
        }
        .padding(10)
        .frame(width: size.width, height: size.height)
    }
}
