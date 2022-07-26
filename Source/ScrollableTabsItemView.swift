//
// Copyright (c) 2021 Shakuro (https://shakuro.com/)
// Sergey Laschuk
//

import Foundation
import UIKit

internal protocol ScrollableTabsItemViewDelegate: AnyObject {
    func scrollableTabsItemViewDidTapButton(_ itemView: ScrollableTabsItemView)
}

internal class ScrollableTabsItemView: UIView {

    private var textLabel: UILabel!
    private var maxWidthConstraint: NSLayoutConstraint!
    private var leadingLabelConstraint: NSLayoutConstraint!
    private var trailingLabelConstraint: NSLayoutConstraint!
    private var button: UIButton!

    private weak var delegate: ScrollableTabsItemViewDelegate?

    private let text: String
    internal let index: Int
    private var textAttributesNormal: [NSAttributedString.Key: Any]
    private var textAttributesSelected: [NSAttributedString.Key: Any]
    private var isSelected: Bool = false

    // MARK: - Initialization

    required init?(coder: NSCoder) {
        fatalError("use init(text:index:labelMargin:numberOfLines:)")
    }

    internal init(text: String,
                  index: Int,
                  labelMargin: CGFloat,
                  numberOfLines: Int,
                  textAttributesNormal: [NSAttributedString.Key: Any],
                  textAttributesSelected: [NSAttributedString.Key: Any],
                  delegate: ScrollableTabsItemViewDelegate) {
        self.text = text
        self.index = index
        self.textAttributesNormal = textAttributesNormal
        self.textAttributesSelected = textAttributesSelected
        self.delegate = delegate

        super.init(frame: CGRect.zero)
        self.backgroundColor = UIColor.clear

        textLabel = UILabel(frame: self.frame)
        textLabel.text = text
        textLabel.numberOfLines = numberOfLines
        textLabel.backgroundColor = UIColor.clear
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(textLabel)
        textLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        textLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        leadingLabelConstraint = textLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: labelMargin)
        leadingLabelConstraint.isActive = true
        trailingLabelConstraint = self.trailingAnchor.constraint(equalTo: textLabel.trailingAnchor, constant: labelMargin)
        trailingLabelConstraint.isActive = true
        textLabel.setContentCompressionResistancePriority(ScrollableTabs.LayoutPriority.itemTextCompressionResistanceHorizontal, for: .horizontal)
        textLabel.setContentCompressionResistancePriority(ScrollableTabs.LayoutPriority.itemTextCompressionResistanceVertical, for: .vertical)
        textLabel.setContentHuggingPriority(ScrollableTabs.LayoutPriority.itemTextHuggingHorizontal, for: .horizontal)
        textLabel.setContentHuggingPriority(ScrollableTabs.LayoutPriority.itemTextHuggingVertical, for: .vertical)

        button = UIButton(frame: self.frame)
        button.backgroundColor = UIColor.clear
        button.setTitle(nil, for: UIControl.State.normal)
        button.addTarget(self, action: #selector(buttonDidTap), for: UIControl.Event.touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(button)
        button.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        button.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        button.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        button.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true

        updateText()
    }

    // MARK: - Public

    internal func setLabelHorizontalMargin(_ newValue: CGFloat) {
        leadingLabelConstraint.constant = newValue
        trailingLabelConstraint.constant = newValue
    }

    internal func setNumberOfLines(_ newValue: Int) {
        textLabel.numberOfLines = newValue
    }

    internal func setTextAttributes(normal: [NSAttributedString.Key: Any], selected: [NSAttributedString.Key: Any]) {
        textAttributesNormal = normal
        textAttributesSelected = selected
        updateText()
    }

    internal func setSelected(_ newValue: Bool) {
        isSelected = newValue
        updateText()
    }

    // MARK: - Interface callbacks

    @objc private func buttonDidTap() {
        delegate?.scrollableTabsItemViewDidTapButton(self)
    }

    // MARK: - Private

    private func updateText() {
        let attributes = isSelected ? textAttributesSelected : textAttributesNormal
        textLabel.attributedText = NSAttributedString(string: text, attributes: attributes)
    }

}
