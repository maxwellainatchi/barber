//
//  ContentView.swift
//  barber
//
//  Created by Max Ainatchi on 7/18/20.
//  Copyright © 2020 Max Ainatchi, Inc. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var outdated = Homebrew.shared.outdated()
        
    var body: some View {
        VStack {
            List(self.outdated.formulae) { entry in
                OutdatedView(entry: entry)
            }
            Button("Quit") {
                exit(0)
            }.padding(.bottom, 10)
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
