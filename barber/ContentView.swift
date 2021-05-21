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
            LoadModelView(load: {
                $0(Result { try Homebrew.shared.outdated() })
            }, state: self.state) { outdated in
                List(outdated.formulae) { entry in
                    OutdatedView(entry: entry)
                }
            }
            Button("Quit") { exit(0) }.padding(.top, 10)
        }
        .padding(10)
        .frame(width: size.width, height: size.height)
    }
}
