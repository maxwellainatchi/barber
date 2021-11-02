//
//  ListModifiers.swift
//  barber
//
//  Created by Maxwell Ainatchi on 11/2/21.
//  Copyright © 2021 Max Ainatchi, Inc. All rights reserved.
//

import Foundation
import SwiftUI

private struct BackgroundColorModifier: ViewModifier {
    let color: Color

    /**
      BEWARE: HERE BE HACKS
      It looks as though `background(_:)` doesn't work on lists for some reason. You can set the background color for
      rows, but it doesn't extend to the padding, extra space, etc.

      The solution is to work around it - UI/NSTableView supports changing the background color, so we use the introspect
      library to access the underlying table view, then modify the color on that directly.
     */
    func body(content: Content) -> some View {
        content.introspectTableView { tableView in
            tableView.backgroundColor = NSColor(self.color)
        }
    }
}

extension List {
    /**
      Hack to work around `background(_:)` not working on Lists. This should be used instead of `background(_:)`
      wherever possible.
     */
    func backgroundColor(color: Color) -> some View {
        self.modifier(BackgroundColorModifier(color: color))
    }
}
