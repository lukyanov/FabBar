import UIKit

/// The root UIKit view that assembles the tab bar with glass effects.
/// Uses UIGlassContainerEffect to enable morphing between the segmented control and FAB.
@available(iOS 26.0, *)
final class GlassTabBarView: UIView {
    let containerEffectView: UIVisualEffectView
    let segmentedGlassView: UIVisualEffectView
    let segmentedControl: TabBarSegmentedControl
    let fabGlassView: UIVisualEffectView
    let fabButton: FabButton

    private let spacing: CGFloat = Constants.fabSpacing
    private let contentPadding: CGFloat = Constants.contentPadding

    private(set) var tabCount: Int
    private var segmentedTrailingConstraint: NSLayoutConstraint?

    /// The newest configuration. Both the tap and the menu read it when they fire rather than
    /// capturing it: a SwiftUI host rebuilds its `FabBarAction` on every state change, so a closure
    /// captured once at init would keep calling into a stale copy of the view.
    private var action: FabBarAction

    init(
        segmentedControl: TabBarSegmentedControl,
        tabCount: Int,
        action: FabBarAction
    ) {
        self.segmentedControl = segmentedControl
        self.tabCount = tabCount
        self.action = action

        // Create glass container effect for morphing
        let containerEffect = UIGlassContainerEffect()
        containerEffect.spacing = Constants.fabSpacing
        containerEffectView = UIVisualEffectView(effect: containerEffect)

        // Create segmented control glass effect
        let segmentedGlassEffect = UIGlassEffect()
        segmentedGlassEffect.isInteractive = true
        segmentedGlassView = UIVisualEffectView(effect: segmentedGlassEffect)

        // Create FAB button
        let fabGlassEffect = UIGlassEffect()
        fabGlassEffect.isInteractive = true
        fabGlassEffect.tintColor = .tintColor
        fabGlassView = UIVisualEffectView(effect: fabGlassEffect)

        let button = FabButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: Constants.fabIconPointSize, weight: .medium)
        let buttonImage = UIImage(systemName: action.systemImage, withConfiguration: config)
        button.setImage(buttonImage, for: .normal)
        button.tintColor = .white
        button.accessibilityLabel = action.accessibilityLabel
        button.accessibilityTraits = .button
        fabButton = button

        super.init(frame: .zero)

        // Ensure tint adjustment mode is automatic so views dim when sheets are presented
        tintAdjustmentMode = .automatic
        fabGlassView.tintAdjustmentMode = .automatic
        fabButton.tintAdjustmentMode = .automatic

        setupViews()
        update(action: action)
    }

    /// Adopts a newly built configuration. The tap and the menu both read `action` when they fire,
    /// so this is all it takes to keep them current: the attached menu is a deferred element that
    /// asks for the newest children each time it opens.
    func update(action: FabBarAction) {
        self.action = action
        if action.menu == nil {
            fabButton.menu = nil
        } else if fabButton.menu == nil {
            fabButton.menu = UIMenu(children: [
                UIDeferredMenuElement.uncached { [weak self] completion in
                    completion(self?.action.menu?.children ?? [])
                }
            ])
            // The tap keeps its meaning; press-and-hold is what opens the menu.
            fabButton.showsMenuAsPrimaryAction = false
        }
        // The menu's own entries, as VoiceOver actions.
        //
        // A hold is a gesture VoiceOver does not have: its double-tap is the button's TAP, which
        // here runs `action`. Without this the menu is reachable by touch and by nothing else, so a
        // secondary action with no other entry point in the host app is simply unavailable. Apple's
        // VoiceOver guidance asks for this by name — a control that overloads a long press should
        // offer the same behaviours through the actions rotor.
        //
        // Rebuilt on every update rather than set once: the host hands down fresh closures, and an
        // action holding a stale one would run the wrong thing.
        fabButton.accessibilityCustomActions = action.menu.map(Self.customActions(for:))
    }

    /// A menu's `UIAction` leaves, as accessibility actions. Nested submenus are flattened out —
    /// a rotor is a flat list, and a group heading is not something it can present.
    private static func customActions(for menu: UIMenu) -> [UIAccessibilityCustomAction] {
        menu.children.flatMap { child -> [UIAccessibilityCustomAction] in
            switch child {
            case let item as UIAction:
                return [UIAccessibilityCustomAction(name: item.title) { _ in
                    item.performWithSender(nil, target: nil)
                    return true
                }]
            case let submenu as UIMenu:
                return customActions(for: submenu)
            default:
                return []
            }
        }
    }

    private func setupViews() {
        // Add container effect view
        addSubview(containerEffectView)
        containerEffectView.translatesAutoresizingMaskIntoConstraints = false

        // Add segmented glass view to container's contentView
        containerEffectView.contentView.addSubview(segmentedGlassView)
        segmentedGlassView.translatesAutoresizingMaskIntoConstraints = false

        // Add segmented control to segmented glass view's contentView
        segmentedGlassView.contentView.addSubview(segmentedControl)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false

        // Add FAB glass view
        containerEffectView.contentView.addSubview(fabGlassView)
        fabGlassView.translatesAutoresizingMaskIntoConstraints = false

        fabGlassView.contentView.addSubview(fabButton)
        fabButton.translatesAutoresizingMaskIntoConstraints = false

        // Goes through the stored action, so the tap cannot go stale — see `update`.
        fabButton.addAction(UIAction { [weak self] _ in self?.action.action() }, for: .touchUpInside)

        // Extra bottom inset compensates for UISegmentedControl's internal padding,
        // visually centering the content within the glass container.
        let segmentedControlBottomInsetAdjustment: CGFloat = 1

        NSLayoutConstraint.activate([
            containerEffectView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerEffectView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerEffectView.topAnchor.constraint(equalTo: topAnchor),
            containerEffectView.bottomAnchor.constraint(equalTo: bottomAnchor),

            segmentedGlassView.leadingAnchor.constraint(equalTo: containerEffectView.contentView.leadingAnchor),
            segmentedGlassView.topAnchor.constraint(equalTo: containerEffectView.contentView.topAnchor),
            segmentedGlassView.bottomAnchor.constraint(equalTo: containerEffectView.contentView.bottomAnchor),

            segmentedControl.leadingAnchor.constraint(equalTo: segmentedGlassView.contentView.leadingAnchor, constant: contentPadding),
            segmentedControl.trailingAnchor.constraint(equalTo: segmentedGlassView.contentView.trailingAnchor, constant: -contentPadding),
            segmentedControl.topAnchor.constraint(equalTo: segmentedGlassView.contentView.topAnchor, constant: contentPadding),
            segmentedControl.bottomAnchor.constraint(equalTo: segmentedGlassView.contentView.bottomAnchor, constant: -contentPadding - segmentedControlBottomInsetAdjustment),

            // FAB glass view
            fabGlassView.trailingAnchor.constraint(equalTo: containerEffectView.contentView.trailingAnchor),
            fabGlassView.topAnchor.constraint(equalTo: containerEffectView.contentView.topAnchor),
            fabGlassView.bottomAnchor.constraint(equalTo: containerEffectView.contentView.bottomAnchor),
            fabGlassView.widthAnchor.constraint(equalTo: fabGlassView.heightAnchor),

            // Fill the entire glass area so taps anywhere trigger the action
            fabButton.leadingAnchor.constraint(equalTo: fabGlassView.contentView.leadingAnchor),
            fabButton.trailingAnchor.constraint(equalTo: fabGlassView.contentView.trailingAnchor),
            fabButton.topAnchor.constraint(equalTo: fabGlassView.contentView.topAnchor),
            fabButton.bottomAnchor.constraint(equalTo: fabGlassView.contentView.bottomAnchor),
        ])

        // Set up the trailing constraint based on tab count
        segmentedTrailingConstraint = makeSegmentedTrailingConstraint()
        segmentedTrailingConstraint?.isActive = true
    }

    /// Creates the appropriate trailing constraint for the segmented glass view.
    /// For 3+ tabs, fills to the FAB. For fewer tabs, floats leading-aligned.
    private func makeSegmentedTrailingConstraint() -> NSLayoutConstraint {
        if tabCount >= 3 {
            segmentedGlassView.trailingAnchor.constraint(equalTo: fabGlassView.leadingAnchor, constant: -spacing)
        } else {
            segmentedGlassView.trailingAnchor.constraint(lessThanOrEqualTo: fabGlassView.leadingAnchor, constant: -spacing)
        }
    }

    /// Updates the tab count and swaps the trailing constraint to match.
    func updateTabCount(_ newCount: Int) {
        guard newCount != tabCount else { return }
        tabCount = newCount
        segmentedTrailingConstraint?.isActive = false
        segmentedTrailingConstraint = makeSegmentedTrailingConstraint()
        segmentedTrailingConstraint?.isActive = true
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // Capsule shape for segmented control
        segmentedGlassView.cornerConfiguration = .capsule()

        // Circle shape for FAB button (capsule with equal width/height = circle)
        fabGlassView.cornerConfiguration = .capsule()
    }

    override func tintColorDidChange() {
        super.tintColorDidChange()
        // Update FAB glass effect tint when tintAdjustmentMode changes
        // Create a new effect since modifying existing effect's tintColor doesn't update visuals
        let newEffect = UIGlassEffect()
        newEffect.isInteractive = true
        newEffect.tintColor = tintColor
        fabGlassView.effect = newEffect
    }
}
