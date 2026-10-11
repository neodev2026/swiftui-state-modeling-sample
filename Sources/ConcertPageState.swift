// Sanitized and simplified excerpt based on production code.
// Project-specific dependencies and business logic have been removed.

import SwiftUI

enum ConcertPageMode {
    case portrait
    case landscapeFitPlayer
    case landscapeFillPlayer
    case landscapeFitPlayerChat
}

final class ConcertPageState: ObservableObject {

    @Published var mode: ConcertPageMode = .portrait {
        didSet {
            updateDerivedState()
        }
    }

    @Published private(set) var ignoredSafeAreaEdge: Edge.Set?

    init() {
        updateDerivedState()
    }

    private func updateDerivedState() {
        switch mode {
        case .portrait:
            ignoredSafeAreaEdge = nil

        case .landscapeFitPlayer,
             .landscapeFillPlayer:
            ignoredSafeAreaEdge = .all

        case .landscapeFitPlayerChat:
            ignoredSafeAreaEdge = nil
        }
    }
}