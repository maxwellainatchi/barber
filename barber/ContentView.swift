//
//  ContentView.swift
//  barber
//
//  Created by Max Ainatchi on 7/18/20.
//  Copyright © 2020 Max Ainatchi, Inc. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    let size: NSSize

    private var modelView: some Reloadable {
        LoadModelView(load: {
            $0(Result { try Homebrew.shared.outdated() })
        }) { outdated in
            List(outdated.formulae) { entry in
                OutdatedView(entry: entry)
            }
        }
    }

    var body: some View {
        VStack {
            self.modelView
            Button("Quit") { exit(0) }.padding(.top, 10)
        }
        .padding(10)
        .frame(width: size.width, height: size.height)
    }

    func reload() {
        self.modelView.reload()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(size: .init(width: 400, height: 400))
    }
}
