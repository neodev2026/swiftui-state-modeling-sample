// Sanitized and simplified excerpt based on production code.
// Project-specific dependencies and business logic have been removed.

import SwiftUI

struct ConcertPlayerView: View {

    @ObservedObject var pageState: ConcertPageState

    var body: some View {
        ZStack {
            Rectangle()
                .fill(.black)

            controls
        }
        .gesture(
            MagnificationGesture()
                .onChanged { value in
                    handleMagnification(value)
                }
        )
    }

    private var controls: some View {
        HStack {
            Button("Fullscreen") {
                toggleFullscreen()
            }

            Button("Chat") {
                toggleChat()
            }
        }
    }

    private func handleMagnification(_ value: CGFloat) {

        switch pageState.mode {
        case .landscapeFitPlayer:
            if value > 1 {
                pageState.mode = .landscapeFillPlayer
            }

        case .landscapeFillPlayer:
            if value < 1 {
                pageState.mode = .landscapeFitPlayer
            }

        default:
            break
        }
    }

    private func toggleChat() {

        switch pageState.mode {
        case .landscapeFitPlayer,
             .landscapeFillPlayer:
            pageState.mode = .landscapeFitPlayerChat

        case .landscapeFitPlayerChat:
            pageState.mode = .landscapeFitPlayer

        default:
            break
        }
    }

    private func toggleFullscreen() {

        switch pageState.mode {
        case .portrait:
            pageState.mode = .landscapeFitPlayer

        case .landscapeFitPlayer,
             .landscapeFillPlayer,
             .landscapeFitPlayerChat:
            pageState.mode = .portrait
        }
    }
}