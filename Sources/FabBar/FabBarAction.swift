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

    /// The icon's colour, drawn over glass tinted with the view's `tintColor`. White by default.
    /// Pass a dynamic colour — an asset catalog colour, say — when the tint is light in some
    /// appearance: a light accent under a white icon leaves the icon without contrast.
    public let foregroundColor: UIColor

    /// A menu anchored to the button, or `nil` (the default) for a button that only taps. Unless
    /// [opensMenuOnTap], it is secondary: presented on press-and-hold, while `action` still runs on
    /// a plain tap, the way a toolbar button carries a menu and keeps its primary action. FabBar
    /// also publishes the menu's entries as VoiceOver custom actions, because a press-and-hold is
    /// not a gesture VoiceOver can perform.
    public let menu: UIMenu?

    /// Whether a plain tap opens [menu]. The button then has no action of its own — an "add" button
    /// whose every choice is in its menu, rather than one obvious action with a few alternatives.
    public let opensMenuOnTap: Bool

    /// The action to perform when the button is tapped.
    public let action: () -> Void

    /// Creates a floating action button configuration.
    ///
    /// - Parameters:
    ///   - systemImage: The SF Symbol name for the button icon.
    ///   - accessibilityLabel: The accessibility label for VoiceOver users.
    ///   - foregroundColor: The icon's colour. Defaults to white.
    ///   - menu: Secondary actions presented on press-and-hold. Defaults to none.
    ///   - action: The action to perform when the button is tapped.
    public init(
        systemImage: String,
        accessibilityLabel: String,
        foregroundColor: UIColor = .white,
        menu: UIMenu? = nil,
        action: @escaping () -> Void
    ) {
        self.systemImage = systemImage
        self.accessibilityLabel = accessibilityLabel
        self.foregroundColor = foregroundColor
        self.menu = menu
        self.opensMenuOnTap = false
        self.action = action
    }

    /// Creates a floating action button whose tap opens [menu].
    ///
    /// - Parameters:
    ///   - systemImage: The SF Symbol name for the button icon.
    ///   - accessibilityLabel: The accessibility label for VoiceOver users.
    ///   - foregroundColor: The icon's colour. Defaults to white.
    ///   - menu: What a tap offers.
    public init(
        systemImage: String,
        accessibilityLabel: String,
        foregroundColor: UIColor = .white,
        opening menu: UIMenu
    ) {
        self.systemImage = systemImage
        self.accessibilityLabel = accessibilityLabel
        self.foregroundColor = foregroundColor
        self.menu = menu
        self.opensMenuOnTap = true
        self.action = {}
    }
}
