import SwiftUI

enum DragModalSize {
    case small // 25%
    case regular // 50%
    case large // 75%
    case fullscreen // 100%
    case custom(height: CGFloat)

    var size: CGFloat {
        switch self {
        case .small:
            return UIScreen.main.bounds.size.height / 4
        case .regular:
            return UIScreen.main.bounds.size.height / 2
        case .large:
            return (UIScreen.main.bounds.size.height / 4) * 3
        case .fullscreen:
            // Remove the safe area for `.fullscreen` mode. You can get this value dynamically.
            return UIScreen.main.bounds.size.height - 44
        case .custom(let height):
            return height
        }
    }
}

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
    private func onDragEnded(drag: DragGesture.Value) {
        let dragThreshold = height.size * (2 / 3)
        if drag.predictedEndTranslation.height > dragThreshold || drag.translation.height > dragThreshold {
            isShown = false
        }
    }

    @Binding var isShown: Bool
    var mainViewColor: Color = .init(white: 0.9)
    var height: DragModalSize = .regular
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
                                    upperLimit: Double(height.size),
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
                        mainViewColor
                            .frame(width: UIScreen.main.bounds.size.width, height: height.size)
                            .cornerRadius(Constants.Content.cornerRadius)
                            .shadow(radius: Constants.Content.shadowRadius)
                        Image(systemName: "minus")
                            .font(.system(size: Constants.DragImage.size))
                            .foregroundColor(Color(.darkGray))
                        content()
                            .padding(.vertical, Constants.Content.verticalPadding)
                            .frame(width: UIScreen.main.bounds.size.width, height: height.size)
                            .clipped()
                    }
                    .offset(
                        y: isShown
                            ? (
                                (dragState.isDragging && dragState.translation.height >= 1)
                                    ? dragState.translation.height
                                    : 0
                            )
                            : height.size)
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
