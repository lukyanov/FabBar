import SwiftUI

/// View modifier that positions a FabBar at the bottom of the view.
///
/// This modifier handles all the layout details:
/// - Wraps in `.safeAreaBar(edge: .bottom)`
/// - Applies appropriate padding
/// - Caps the bar's width so it stays a thumb-sized control on a wide screen
/// - Ignores bottom safe area for manual positioning
/// - Injects calculated safe area padding into the environment
///
/// Whether the bar belongs on a given screen is the caller's decision, through `isVisible`. The
/// modifier draws no conclusion from the size class: a wide screen can still be a phone screen
/// that wants this bar, and a narrow one can be an iPad in Slide Over that does not.
///
/// `isCovered` is the other reason the bar stands down: a screen pushed over the tab's content.
/// Only `isVisible` withdraws the room `fabBarSafeAreaPadding()` reserves. The covered content
/// keeps it, because it is not on screen to use the space — and a scroll view that lost it while
/// scrolled to its end would be clamped back, and come out from under the pushed screen short of
/// where it was left.
@available(iOS 26.0, *)
struct FabBarModifier<Value: Hashable>: ViewModifier {
    @Binding var selection: Value
    let tabs: [FabBarTab<Value>]
    let action: FabBarAction
    let isVisible: Bool
    let isCovered: Bool

    @State private var bottomSafeAreaInset: CGFloat = 0

    /// Total content margin needed to clear the FabBar.
    private var bottomContentMargin: CGFloat {
        Constants.barHeight + Constants.bottomPadding
    }

    /// The padding to inject into the environment.
    /// This is the total content margin minus the device's safe area inset,
    /// because `safeAreaPadding` adds to the existing safe area.
    /// Returns 0 when the FabBar does not belong here; a covered bar keeps its room.
    private var calculatedPadding: CGFloat {
        isVisible ? bottomContentMargin - bottomSafeAreaInset : 0
    }

    private var drawsBar: Bool { isVisible && !isCovered }

    func body(content: Content) -> some View {
        content
            .safeAreaBar(edge: .bottom) {
                if drawsBar {
                    FabBar(selection: $selection, tabs: tabs, action: action)
                        .frame(maxWidth: Constants.maxBarWidth)
                        .padding(.horizontal, Constants.horizontalPadding)
                        .padding(.bottom, Constants.bottomPadding)
                }
            }
            .ignoresSafeArea(.all, edges: drawsBar ? [.bottom] : [])
            .onGeometryChange(for: CGFloat.self) { proxy in
                proxy.safeAreaInsets.bottom
            } action: { newValue in
                bottomSafeAreaInset = newValue
            }
            .environment(\.fabBarBottomSafeAreaPadding, calculatedPadding)
    }
}

@available(iOS 26.0, *)
public extension View {
    /// Adds a FabBar to the bottom of the view.
    ///
    /// This is the recommended way to use FabBar. It handles positioning and safe area management.
    /// Pass `isVisible` to say where the bar belongs — for example `horizontalSizeClass == .compact`
    /// to keep it off the iPad, where the native tab bar serves instead.
    ///
    /// ```swift
    /// TabView(selection: $selectedTab) {
    ///     Tab(value: .home) {
    ///         HomeView()
    ///             .fabBarSafeAreaPadding()
    ///             .toolbarVisibility(.hidden, for: .tabBar)
    ///     }
    ///     // more tabs...
    /// }
    /// .fabBar(selection: $selectedTab, tabs: tabs, action: action)
    /// ```
    ///
    /// - Parameters:
    ///   - selection: A binding to the currently selected tab.
    ///   - tabs: The tabs to display.
    ///   - action: The floating action button configuration.
    ///   - isVisible: Whether the FabBar belongs here. Defaults to `true`.
    ///   - isCovered: Whether a screen pushed over the tab's content covers it. The bar stands down,
    ///     and the content keeps the room it reserves for the bar, so a list scrolled to its end is
    ///     still there when the pushed screen goes. Defaults to `false`.
    func fabBar<Value: Hashable>(
        selection: Binding<Value>,
        tabs: [FabBarTab<Value>],
        action: FabBarAction,
        isVisible: Bool = true,
        isCovered: Bool = false
    ) -> some View {
        modifier(FabBarModifier(
            selection: selection,
            tabs: tabs,
            action: action,
            isVisible: isVisible,
            isCovered: isCovered
        ))
    }
}
