// Sanitized and simplified excerpt based on production code.
// Project-specific dependencies and business logic have been removed.

import SwiftUI

struct ConcertPageView: View {

    @StateObject private var pageState = ConcertPageState()

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {

                if headerHeight() > 0 {
                    header
                        .frame(height: headerHeight())
                }

                HStack(spacing: 0) {

                    player
                        .frame(
                            width: playerWidth(in: geometry)
                        )

                    if pageState.mode == .landscapeFitPlayerChat {
                        chat
                            .frame(
                                width: geometry.size.width / 2
                            )
                    }
                }
            }
            .ignoresSafeArea(
                pageState.ignoredSafeAreaEdge ?? []
            )
        }
    }

    private var header: some View {
        Text("Concert")
            .frame(maxWidth: .infinity)
    }

    private var player: some View {
        ConcertPlayerView(pageState: pageState)
    }

    private var chat: some View {
        Text("Chat")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func playerWidth(
        in geometry: GeometryProxy
    ) -> CGFloat {

        switch pageState.mode {
        case .portrait,
             .landscapeFitPlayer,
             .landscapeFillPlayer:
            return geometry.size.width

        case .landscapeFitPlayerChat:
            return geometry.size.width / 2
        }
    }

    private func headerHeight() -> CGFloat {

        switch pageState.mode {
        case .portrait:
            return 44

        case .landscapeFitPlayer,
             .landscapeFillPlayer,
             .landscapeFitPlayerChat:
            return 0
        }
    }
}