//
//  InfoView.swift
//  barber
//
//  Created by Max Ainatchi on 5/20/21.
//  Copyright © 2021 Max Ainatchi, Inc. All rights reserved.
//

import Foundation
import SwiftUI

struct UnderlyingInfoView: View {
    var info: Homebrew.InfoEntry

    var body: some View {
        if info.deprecated, let deprecationDate = info.deprecationDate {
            Text("Deprecated as of \(DateFormatter().string(from: deprecationDate)) due to \"\(info.deprecationReason ?? "")\"")
        }
        Text(info.desc).lineLimit(nil)
        Link("Homepage", destination: info.homepage)
    }
}

struct InfoView: View {
    @ObservedObject var state: LoadState<Homebrew.InfoResponse>

    var body: some View {
        LoadModelView(state: self.state) { response in
            VStack {
                if let info = response.formulae.first ?? response.casks.first {
                    UnderlyingInfoView(info: info)
                } else {
                    Text("An error occurred!")
                }
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
