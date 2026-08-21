import UIKit

/// The FAB itself.
///
/// It exists as a subclass for one reason: to answer a press-and-hold with a knock. UIKit plays
/// the hold feedback only for a context menu that shows a *preview*; a control that presents its
/// `menu` on a hold presents silently, so the finger gets no reply until the menu has drawn.
/// `UIControl` publishes the presentation callback for exactly this kind of addition.
@available(iOS 26.0, *)
final class FabButton: UIButton {
    /// Kept alive between presses so the Taptic engine is already warm when the hold completes —
    /// a generator built at fire time answers late enough to read as a lag.
    private let holdFeedback = UIImpactFeedbackGenerator(style: .medium)

    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        holdFeedback.prepare()
        return super.beginTracking(touch, with: event)
    }

    override func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        willDisplayMenuFor configuration: UIContextMenuConfiguration,
        animator: UIContextMenuInteractionAnimating?
    ) {
        super.contextMenuInteraction(interaction, willDisplayMenuFor: configuration, animator: animator)
        holdFeedback.impactOccurred()
    }
}
