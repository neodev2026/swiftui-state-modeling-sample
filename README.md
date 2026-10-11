# SwiftUI State Modeling Sample

This repository is intentionally small.

It contains a sanitized and simplified excerpt based on a production iOS application I rebuilt with SwiftUI.

The sample focuses on one design decision: how I modeled a complex concert screen as a small set of explicit UI states instead of combining multiple Boolean flags.

Project-specific dependencies, APIs, DRM details, business logic, and customer information have been removed.

---

## Context

The original application was a live-entertainment service with React frontend, Java backend, iOS, and Android clients.

I was responsible for maintaining the React frontend and iOS application while leading three developers.

Later, I participated in the iOS/Android renewal. SwiftUI was new to me at the time, so I approached it by first following the project conventions, then learning SwiftUI's state-driven model and redesigning the screen around it rather than translating the existing UIKit structure directly.

One of the most complex parts was the concert screen, which had to support:

- portrait mode
- landscape fullscreen
- fit / fill player modes
- chat alongside the player
- gesture-based transitions
- different safe-area and layout behavior depending on the current mode

---

## The Problem

A straightforward implementation could represent the screen with several independent Boolean values:

```swift
var isPortrait: Bool
var isFullscreen: Bool
var isFillMode: Bool
var isChatVisible: Bool
```

That looks simple at first, but four independent Boolean values can represent sixteen combinations.

Most of those combinations do not make sense for the actual UI.

For example:

- portrait + fullscreen
- fill mode while not fullscreen
- chat visible in an unsupported layout

The more conditions accumulate, the harder it becomes to reason about which combinations are valid and how one interaction affects the others.

---

## The Design Decision

Instead of representing the UI as unrelated flags, I modeled the valid screen states explicitly:

```swift
enum ConcertPageMode {
    case portrait
    case landscapeFitPlayer
    case landscapeFillPlayer
    case landscapeFitPlayerChat
}
```

The important idea is simple:

> If only four states are valid, represent four states.

This makes invalid combinations harder to represent in the first place.

The rest of the UI can then be derived from this single state.

---

## 1. Explicit State

[`ConcertPageState.swift`](Sources/ConcertPageState.swift) defines the allowed screen modes and state derived from them.

For example, safe-area behavior is determined from the current mode instead of being controlled independently by several flags.

```swift
switch mode {
case .portrait:
    ignoredSafeAreaEdge = nil

case .landscapeFitPlayer,
     .landscapeFillPlayer:
    ignoredSafeAreaEdge = .all

case .landscapeFitPlayerChat:
    ignoredSafeAreaEdge = nil
}
```

This keeps related behavior tied to the state that explains why it exists.

---

## 2. State-Derived Layout

[`ConcertPageView.swift`](Sources/ConcertPageView.swift) derives layout directly from `ConcertPageMode`.

For example:

```swift
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
```

The view does not need to ask a chain of questions such as:

```swift
if isLandscape && isFullscreen && isChatVisible ...
```

It only needs to answer:

> What should this layout look like in the current valid state?

That makes the relationship between state and UI easier to read.

---

## 3. Interactions as State Transitions

[`ConcertPlayerView.swift`](Sources/ConcertPlayerView.swift) handles user interactions by moving between explicit states.

For example, the chat button changes the current mode:

```swift
switch pageState.mode {
case .landscapeFitPlayer,
     .landscapeFillPlayer:
    pageState.mode = .landscapeFitPlayerChat

case .landscapeFitPlayerChat:
    pageState.mode = .landscapeFitPlayer

default:
    break
}
```

Pinch gestures similarly move between fit and fill modes.

This makes interactions easier to understand as transitions between known states instead of side effects on several unrelated variables.

---

## Why I Think This Is Good Code

My definition of great code is not "clever code."

For me, great code makes the problem easier to reason about.

In this case, the important part is not the enum itself. The important part is that the code reflects the actual structure of the problem.

The screen has a small number of valid modes, so the implementation also has a small number of explicit modes.

That gives several practical benefits:

- invalid combinations are harder to create
- layout rules are easier to locate
- interactions are easier to understand
- future changes have a clearer place to go
- the next engineer has less hidden state to reconstruct mentally

I also wrote this code with handover in mind.

The developer who would maintain the application after me was primarily a backend engineer, so I intentionally used predictable responsibilities and naming across Model / DAO / Service / State / Page / View layers.

During handover, he told me that he could understand the code without additional documentation or explanation.

For me, that was a useful measure of maintainability.

---

## What I Would Improve Today

I would not call this code perfect.

Looking at it a few years later, I would centralize state transitions further and add automated tests around the allowed transition paths.

I would also revisit some dependency and concurrency choices using the current Swift concurrency model.

The architecture was a significant improvement over the previous implementation, but there is still room to make the state model more centralized and testable.

---

## Why This Sample

I chose this sample because it represents how I think about engineering.

I do not start with a framework pattern and force the problem into it.

I first try to understand:

- what the real states are
- what combinations should be impossible
- what the next engineer needs to understand
- which decisions should be visible in the structure of the code

Then I choose the simplest structure that makes those decisions explicit.

That is what I mean by maintainable code.

---

## Files

- [`ConcertPageState.swift`](Sources/ConcertPageState.swift)
- [`ConcertPageView.swift`](Sources/ConcertPageView.swift)
- [`ConcertPlayerView.swift`](Sources/ConcertPlayerView.swift)

---

## Note

This repository contains a sanitized and simplified excerpt based on production code.

Customer-specific implementation details, proprietary business logic, APIs, DRM configuration, credentials, and unrelated application code have been removed.
