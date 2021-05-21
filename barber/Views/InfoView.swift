//
//  InfoView.swift
//  barber
//
//  Created by Max Ainatchi on 5/20/21.
//  Copyright © 2021 Max Ainatchi, Inc. All rights reserved.
//

import Foundation
import SwiftUI

struct InfoView: View {
    @ObservedObject var state: LoadState<Homebrew.InfoResponse, Error>
    
    var body: some View {
        LoadModelView(state: self.state) { response in
            Code(text: response.formulae.count.description)
        }
    }
}
