import UIKit

/// Configuration for the floating action button (FAB) in FabBar.
///
/// The FAB appears as a circular glass button next to the tab items,
/// morphing with the iOS 26 glass effect.
@available(iOS 26.0, *)
public struct FabBarAction {
    /// The SF Symbol name for the button icon.
    public let systemImage: String

    /// The accessibility label for VoiceOver users.
    public let accessibilityLabel: String

    /// Secondary actions, presented as a menu when the button is pressed and held, or `nil` (the
    /// default) for a button that only taps. The menu never replaces the tap: `action` still runs
    /// on a plain tap, the way a toolbar button carries a menu while keeping its primary action.
    /// UIKit anchors the menu to the button; FabBar additionally publishes the menu's entries as
    /// VoiceOver custom actions, because a press-and-hold is not a gesture VoiceOver can perform.
    public let menu: UIMenu?

    /// The action to perform when the button is tapped.
    public let action: () -> Void

    /// Creates a floating action button configuration.
    ///
    /// - Parameters:
    ///   - systemImage: The SF Symbol name for the button icon.
    ///   - accessibilityLabel: The accessibility label for VoiceOver users.
    ///   - menu: Secondary actions presented on press-and-hold. Defaults to none.
    ///   - action: The action to perform when the button is tapped.
    public init(
        systemImage: String,
        accessibilityLabel: String,
        menu: UIMenu? = nil,
        action: @escaping () -> Void
    ) {
        self.systemImage = systemImage
        self.accessibilityLabel = accessibilityLabel
        self.menu = menu
        self.action = action
    }
}
