//
// Copyright (c) 2021 Shakuro (https://shakuro.com/)
// Sergey Laschuk
//

import UIKit

public protocol ScrollableTabsDelegate: AnyObject {
    /// Called when **user** selects another item.
    /// Will not be called if user tries to select already selected item.
    /// Will be called right after the start of selection animation (if animation is enabled).
    func scrollableTabs(_ control: ScrollableTabs, didSelectItem itemIndex: Int)
}

/// Tabbar-like control.
/// Intended to be used above switchable content area & take whole width of the screen.
public class ScrollableTabs: UIView {

    internal enum LayoutPriority {
        static let emptyContentWidth = UILayoutPriority(rawValue: 803)
        static let contentWidthUpper = UILayoutPriority(rawValue: 899)
        static let itemMaxWidth = UILayoutPriority(rawValue: 1000) // item ,ust allow next item to peak from out of screen
        static let itemPreferableWidth = UILayoutPriority(rawValue: 800) // item wants to be width of screen
        static let itemsEqualWidth = UILayoutPriority(rawValue: 802)
        static let itemTextCompressionResistanceHorizontal = UILayoutPriority(rawValue: 900)
        static let itemTextCompressionResistanceVertical = UILayoutPriority(rawValue: 1000)
        static let itemTextHuggingHorizontal = UILayoutPriority(rawValue: 801)
        static let itemTextHuggingVertical = UILayoutPriority(rawValue: 900)
        static let selectionMarkerNoSelectionCenterX = UILayoutPriority(rawValue: 900)
        static let selectionMarkerNoSelectionWidth = UILayoutPriority(rawValue: 200)
        static let selectionMarkerSelectionWidth = UILayoutPriority(rawValue: 201)
    }

    private struct ItemData {
        internal let itemView: ScrollableTabsItemView
        internal let maxWidthConstraint: NSLayoutConstraint
    }

    public static let noSelectionIndex: Int = -1

    /// Delegate
    public weak var delegate: ScrollableTabsDelegate?

    /// Duration of animation of changing selected item when performed by user.
    /// Programmatic selection is not animated by default.
    /// Value of 0 or less will disable animation completely.
    /// Default value is 0.3 seconds.
    public var selectionAnimationDuration: TimeInterval = 0.3

    public var accessibilitySelectedTitle: String?

    /// Scroll view with views, corresponding to items.
    private var contentScrollView: UIScrollView!
    private var contentView: UIView!
    private var itemsContainerView: UIView!
    private var itemsContainerViewTopConstraint: NSLayoutConstraint!
    private var itemsContainerViewBottomConstraint: NSLayoutConstraint!
    private var items: [ItemData] = []
    private var selectionMarker: UIView!
    private var selectionMarkerHeightConstraint: NSLayoutConstraint!
    private var markerNoSelectionCenterXConstraint: NSLayoutConstraint!
    private var markerNoSelectionWidthConstraint: NSLayoutConstraint!
    private var selectionMarkerXCenterConstraint: NSLayoutConstraint?
    private var selectionMarkerWidthConstraint: NSLayoutConstraint?

    /// Index of currently selected item.
    private var currentSelectedItemIndex: Int = ScrollableTabs.noSelectionIndex
    private var currentItemLabelHorizontalMargin: CGFloat = 10.0
    private var currentNextItemMinPeakingWidth: CGFloat = 20.0
    private var currentItemNumberOfLines: Int = 1
    private var currentTextAttributesNormal: [NSAttributedString.Key: Any] = [:]
    private var currentTextAttributesSelected: [NSAttributedString.Key: Any] = [:]

    // MARK: - Initialization

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        contentScrollView = UIScrollView(frame: bounds)
        contentScrollView.backgroundColor = UIColor.clear
        contentScrollView.showsVerticalScrollIndicator = false
        contentScrollView.showsHorizontalScrollIndicator = false
        contentScrollView.bounces = false
        contentScrollView.alwaysBounceHorizontal = false
        contentScrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentScrollView)
        contentScrollView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        contentScrollView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        contentScrollView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        contentScrollView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true

        contentView = UIView(frame: bounds)
        contentView.backgroundColor = UIColor.clear
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentScrollView.addSubview(contentView)
        contentView.topAnchor.constraint(equalTo: contentScrollView.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: contentScrollView.bottomAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: contentScrollView.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: contentScrollView.trailingAnchor).isActive = true
        contentView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        let emptyContentWidthConstraint = contentView.widthAnchor.constraint(equalTo: self.widthAnchor)
        emptyContentWidthConstraint.priority = LayoutPriority.emptyContentWidth
        emptyContentWidthConstraint.isActive = true
        let contentWidthUpperConstraint = contentScrollView.widthAnchor.constraint(lessThanOrEqualTo: self.widthAnchor)
        contentWidthUpperConstraint.priority = LayoutPriority.contentWidthUpper
        contentWidthUpperConstraint.isActive = true

        itemsContainerView = UIView(frame: bounds)
        itemsContainerView.backgroundColor = UIColor.clear
        itemsContainerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(itemsContainerView)
        itemsContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        itemsContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        itemsContainerViewTopConstraint = itemsContainerView.topAnchor.constraint(equalTo: contentView.topAnchor)
        itemsContainerViewTopConstraint.isActive = true
        itemsContainerViewBottomConstraint = contentView.bottomAnchor.constraint(equalTo: itemsContainerView.bottomAnchor)
        itemsContainerViewBottomConstraint.isActive = true

        selectionMarker = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 4))
        selectionMarker.backgroundColor = UIColor.systemBlue
        selectionMarker.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(selectionMarker)
        selectionMarker.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        markerNoSelectionCenterXConstraint = selectionMarker.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        markerNoSelectionCenterXConstraint.priority = LayoutPriority.selectionMarkerNoSelectionCenterX
        markerNoSelectionCenterXConstraint.isActive = true
        markerNoSelectionWidthConstraint = selectionMarker.widthAnchor.constraint(equalToConstant: 0)
        markerNoSelectionWidthConstraint.priority = LayoutPriority.selectionMarkerNoSelectionWidth
        markerNoSelectionWidthConstraint.isActive = true
        selectionMarkerWidthConstraint = nil // no selection
        selectionMarkerXCenterConstraint = nil // no selection
        selectionMarkerHeightConstraint = selectionMarker.heightAnchor.constraint(equalToConstant: 4)
        selectionMarkerHeightConstraint.isActive = true
    }

    // MARK: - Public

    /// If `true` - allows bounce if content is scrollable.
    public var allowBounce: Bool {
        get {
            return contentScrollView.bounces
        }
        set {
            contentScrollView.bounces = newValue
        }
    }

    /// If `true` - allows bounce even is content is not scrollable.
    public var allowAlwaysBounce: Bool {
        get {
            return contentScrollView.alwaysBounceHorizontal
        }
        set {
            contentScrollView.alwaysBounceHorizontal = newValue
        }
    }

    /// Space between item and top of control.
    /// Text is centered inside each item.
    /// Animateable.
    public var itemsTopMargin: CGFloat {
        get {
            return itemsContainerViewTopConstraint.constant
        }
        set {
            itemsContainerViewTopConstraint.constant = newValue
        }
    }

    /// Space between item and bottom of control.
    /// Increase this if selection marker overlap items too much.
    /// Text is centered inside each item.
    /// Animateable.
    public var itemsBottomMargin: CGFloat {
        get {
            return itemsContainerViewBottomConstraint.constant
        }
        set {
            itemsContainerViewBottomConstraint.constant = newValue
        }
    }

    /// Left & right minimum margin for text in item cells.
    /// Default value is 10.0
    /// Animateable.
    public var itemLabelHorizontalMargin: CGFloat {
        get {
            return currentItemLabelHorizontalMargin
        }
        set {
            currentItemLabelHorizontalMargin = newValue
            let maxWidthConstant = calculateItemMaxWidthConstant(itemsNumber: items.count)
            items.forEach({
                $0.itemView.setLabelHorizontalMargin(newValue)
                $0.maxWidthConstraint.constant = maxWidthConstant
            })
        }
    }

    /// If there is more than single item: how much text of the next/previous item is peaking from out of the screen.
    /// This is minimum value: if current item is short - next items can be fully visible.
    /// Single item will always fill full width.
    /// Default value is 20.0
    /// Animateable.
    /// - warning: too big value will produce bad layout.
    public var nextItemMinPeakingWidth: CGFloat {
        get {
            return currentNextItemMinPeakingWidth
        }
        set {
            currentNextItemMinPeakingWidth = newValue
            let maxWidthConstant = calculateItemMaxWidthConstant(itemsNumber: items.count)
            items.forEach({ $0.maxWidthConstraint.constant = maxWidthConstant })
        }
    }

    /// Number of lines of text in items.
    /// Animateable.
    public var itemNumberOfLines: Int {
        get {
            return currentItemNumberOfLines
        }
        set {
            currentItemNumberOfLines = newValue
            items.forEach({ $0.itemView.setNumberOfLines(newValue) })
        }
    }

    /// Color of the selection marker.
    /// Animateable.
    public var selectionMarkerColor: UIColor? {
        get {
            return selectionMarker.backgroundColor
        }
        set {
            selectionMarker.backgroundColor = newValue
        }
    }

    /// Height of selection marker.
    /// Default balue is 4.0
    /// Animateable.
    public var selectionMarkerHeight: CGFloat {
        get {
            return selectionMarkerHeightConstraint.constant
        }
        set {
            selectionMarkerHeightConstraint.constant = newValue
        }
    }

    /// Change content to new items.
    /// - parameter items: new items - new content. Default value is [].
    /// - parameter selectedIndex: index of selected item. Invalid index will remove selection. Default value is -1.
    public func set(items newItems: [String], selectedItemIndex newSelectedItemIndex: Int) {
        items.forEach({ $0.itemView.removeFromSuperview() })
        items.removeAll()
        let maxWidthConstant = calculateItemMaxWidthConstant(itemsNumber: newItems.count)
        var previousItemView: ScrollableTabsItemView?
        for (index, newItem) in newItems.enumerated() {
            let itemView = ScrollableTabsItemView(text: newItem,
                                                  index: index,
                                                  labelMargin: currentItemLabelHorizontalMargin,
                                                  numberOfLines: 1,
                                                  textAttributesNormal: currentTextAttributesNormal,
                                                  textAttributesSelected: currentTextAttributesSelected,
                                                  accessibilitySelectedTitle: accessibilitySelectedTitle,
                                                  delegate: self)
            itemView.translatesAutoresizingMaskIntoConstraints = false
            itemsContainerView.addSubview(itemView)
            itemView.topAnchor.constraint(equalTo: itemsContainerView.topAnchor).isActive = true
            itemView.bottomAnchor.constraint(equalTo: itemsContainerView.bottomAnchor).isActive = true
            if let localPreviousItemView = previousItemView {
                itemView.leadingAnchor.constraint(equalTo: localPreviousItemView.trailingAnchor).isActive = true
                let equalWidthConstraint = itemView.widthAnchor.constraint(equalTo: items[0].itemView.widthAnchor)
                equalWidthConstraint.priority = LayoutPriority.itemsEqualWidth
                equalWidthConstraint.isActive = true
            } else {
                itemView.leadingAnchor.constraint(equalTo: itemsContainerView.leadingAnchor).isActive = true
            }
            let maxWidthConstraint = itemView.widthAnchor.constraint(lessThanOrEqualTo: contentScrollView.widthAnchor,
                                                                     constant: maxWidthConstant)
            maxWidthConstraint.priority = LayoutPriority.itemMaxWidth
            maxWidthConstraint.isActive = true
            let preferableItemWidthConstraint = itemView.widthAnchor.constraint(equalTo: contentScrollView.widthAnchor)
            preferableItemWidthConstraint.priority = LayoutPriority.itemPreferableWidth
            preferableItemWidthConstraint.isActive = true
            items.append(ItemData(itemView: itemView, maxWidthConstraint: maxWidthConstraint))
            previousItemView = itemView
        }
        if let localPreviousItemView = previousItemView {
            localPreviousItemView.trailingAnchor.constraint(equalTo: itemsContainerView.trailingAnchor).isActive = true
        }
        selectedItemIndex = newSelectedItemIndex
    }

    /// Selected item index.
    /// Out-of-bounds value will remove selection.
    /// Not animated. Not affected by `selectionAnimationDuration`.
    /// Animateable.
    /// Will not call `delegate.scrollableTabs(:didSelectItem:)`
    public var selectedItemIndex: Int {
        get {
            return currentSelectedItemIndex
        }
        set {
            if newValue >= 0, newValue < items.count {
                currentSelectedItemIndex = newValue
            } else {
                currentSelectedItemIndex = ScrollableTabs.noSelectionIndex
            }
            updateSelectionUI()
        }
    }

    /// - parameter normal: text attributes for not-selected item state
    /// - parameter selected: text attributes for selected item state
    public func setTextAttributes(normal: [NSAttributedString.Key: Any], selected: [NSAttributedString.Key: Any]) {
        currentTextAttributesNormal = normal
        currentTextAttributesSelected = selected
        items.forEach({ $0.itemView.setTextAttributes(normal: normal, selected: selected) })
    }

}

// MARK: - ScrollableTabsItemViewDelegate

extension ScrollableTabs: ScrollableTabsItemViewDelegate {

    internal func scrollableTabsItemViewDidTapButton(_ itemView: ScrollableTabsItemView) {
        let newIndex = itemView.index
        guard newIndex != currentSelectedItemIndex else {
            return
        }
        if selectionAnimationDuration > 0 {
            UIView.animate(withDuration: selectionAnimationDuration, animations: {
                self.selectedItemIndex = newIndex
                self.layoutIfNeeded()
            })
        } else {
            self.selectedItemIndex = newIndex
        }
        delegate?.scrollableTabs(self, didSelectItem: newIndex)
    }

}

// MARK: - Private

private extension ScrollableTabs {

    private func calculateItemMaxWidthConstant(itemsNumber: Int) -> CGFloat {
        if itemsNumber > 2 {
            return -(currentItemLabelHorizontalMargin + currentNextItemMinPeakingWidth) * 2.0
        } else if itemsNumber == 2 {
            return -(currentItemLabelHorizontalMargin + currentNextItemMinPeakingWidth)
        } else {
            return 0.0
        }
    }

    private func updateSelectionUI() {
        if let oldConstraint = selectionMarkerWidthConstraint {
            selectionMarkerWidthConstraint = nil
            contentView.removeConstraint(oldConstraint)
        }
        if let oldConstraint = selectionMarkerXCenterConstraint {
            selectionMarkerXCenterConstraint = nil
            contentView.removeConstraint(oldConstraint)
        }
        if currentSelectedItemIndex >= 0, currentSelectedItemIndex < items.count {
            markerNoSelectionCenterXConstraint.isActive = false
            markerNoSelectionWidthConstraint.isActive = false
            let itemView = items[currentSelectedItemIndex].itemView
            var targetOffsetX = itemView.frame.midX - contentScrollView.frame.width * 0.5
            targetOffsetX = max(0, min(targetOffsetX, contentScrollView.contentSize.width - contentScrollView.frame.width))
            contentScrollView.contentOffset.x = targetOffsetX
            selectionMarkerWidthConstraint = selectionMarker.widthAnchor.constraint(equalTo: itemView.widthAnchor)
            selectionMarkerWidthConstraint?.priority = LayoutPriority.selectionMarkerSelectionWidth
            selectionMarkerWidthConstraint?.isActive = true
            selectionMarkerXCenterConstraint = selectionMarker.centerXAnchor.constraint(equalTo: itemView.centerXAnchor)
            selectionMarkerXCenterConstraint?.isActive = true
        } else {
            markerNoSelectionCenterXConstraint.isActive = true
            markerNoSelectionWidthConstraint.isActive = true
        }
        items.forEach({ (item: ItemData) -> Void in
            item.itemView.setSelected(item.itemView.index == currentSelectedItemIndex)
        })
    }

}
