# DragModalView
DragModalView using SwiftUI


```swift
private enum DragState {
    case inactive
    case dragging(translation: CGSize)

    var translation: CGSize {
        switch self {
        case .inactive:
            return .zero
        case .dragging(let translation):
            return translation
        }
    }

    var isDragging: Bool {
        switch self {
        case .inactive:
            return false
        case .dragging:
            return true
        }
    }
}

struct DragModalView<Content: View>: View {

    @GestureState private var dragState = DragState.inactive
    @Binding var isShown: Bool

    private func onDragEnded(drag: DragGesture.Value) {
        let dragThreshold = modalHeight * (2 / 3)
        if drag.predictedEndTranslation.height > dragThreshold || drag.translation.height > dragThreshold {
            isShown = false
        }
    }
    var modalHeight: CGFloat = 400
    var content: () -> Content

    // MARK: - Body

    var body: some View {
        let drag = DragGesture()
            .updating($dragState) { drag, state, _ in
                state = .dragging(translation: drag.translation)
            }
            .onEnded(onDragEnded)

        return Group {
            ZStack {
                Spacer()
                    .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                    .background(
                        isShown
                            ? Color.black.opacity(
                                0.5 * fractionProgress(
                                    lowerLimit: 0,
                                    upperLimit: Double(modalHeight),
                                    current: Double(dragState.translation.height),
                                    inverted: true
                                )
                            )
                            : Color.clear
                    )
                    .ignoresSafeArea()
                    .animation(
                        .interpolatingSpring(
                            stiffness: Constants.Animation.stiffness,
                            damping: Constants.Animation.damping,
                            initialVelocity: Constants.Animation.initialVelocity
                        )
                    )
                    .gesture(
                        TapGesture()
                            .onEnded { _ in isShown = false }
                    )
                VStack {
                    Spacer()
                    ZStack(alignment: .top) {
                        Color.evzLightModeBackground
                            .frame(width: UIScreen.main.bounds.size.width, height: modalHeight)
                            .cornerRadius(Constants.Content.cornerRadius)
                            .shadow(radius: Constants.Content.shadowRadius)
                        Image(systemName: "minus")
                            .font(.system(size: Constants.DragImage.size))
                            .foregroundColor(Color.evzPrimaryPurple)
                            .isHidden(!isShown)
                        content()
                            .padding(.vertical, Constants.Content.verticalPadding)
                            .frame(width: UIScreen.main.bounds.size.width, height: modalHeight)
                            .clipped()
                    }
                    .offset(
                        y: isShown
                            ? (
                                (dragState.isDragging && dragState.translation.height >= 1)
                                    ? dragState.translation.height
                                    : 0
                            )
                            : modalHeight)
                    .animation(
                        .interpolatingSpring(
                            stiffness: Constants.Animation.stiffness,
                            damping: Constants.Animation.damping,
                            initialVelocity: Constants.Animation.initialVelocity
                        )
                    )
                    .gesture(drag)
                }
            }
        }
    }
}

// MARK: -

private enum Constants {

    enum DragImage {
        static let size: CGFloat = 80
    }

    enum Content {
        static let verticalPadding: CGFloat = 24
        static let cornerRadius: CGFloat = 10
        static let shadowRadius: CGFloat = 5
    }

    enum Animation {
        static let stiffness: Double = 300.0
        static let damping: Double = 30.0
        static let initialVelocity: Double = 10.0
    }
}

// MARK: - Helpers

private func fractionProgress(
    lowerLimit: Double = 0,
    upperLimit: Double,
    current: Double,
    inverted: Bool = false
) -> Double {

    var val: Double = 0

    if current >= upperLimit {
        val = 1
    } else if current <= lowerLimit {
        val = 0
    } else {
        val = (current - lowerLimit) / (upperLimit - lowerLimit)
    }

    return inverted ? (1 - val) : val
}
```
