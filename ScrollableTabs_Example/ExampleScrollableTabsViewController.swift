//
// Copyright (c) 2022 Shakuro (https://shakuro.com/)
//

import UIKit
import ScrollableTabs_Framework

internal class ExampleScrollableTabsViewController: UIViewController {

    private enum Constant {
        static let defaultAnimationDuration: TimeInterval = 0.3
    }

    @IBOutlet private var tabsControl: ScrollableTabs!
    @IBOutlet private var controlsScrollView: UIScrollView!
    @IBOutlet private var applyChangesAnimatedSwitch: UISwitch!
    @IBOutlet private var newItemsTextView: UITextView!
    @IBOutlet private var newItemsSelectedIndexTextField: UITextField!
    @IBOutlet private var allowBounceSwitch: UISwitch!
    @IBOutlet private var allowAlwaysBounceSwitch: UISwitch!
    @IBOutlet private var itemsTopMarginTextField: UITextField!
    @IBOutlet private var itemsBottomMarginTextField: UITextField!
    @IBOutlet private var itemLabelHorizontalMarginTextField: UITextField!
    @IBOutlet private var nextItemMinPeakingWidthTextField: UITextField!
    @IBOutlet private var itemNumberOfLinesTextField: UITextField!
    @IBOutlet private var selectedItemIndexTextField: UITextField!
    @IBOutlet private var selectionMarkerHeightTextField: UITextField!

    // MARK: - Initialization

    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Scrollable tabs", comment: "")
        tabsControl.delegate = self
        applyChangesAnimatedSwitch.isOn = true
        let items = ["FIRST",
                     "HO HO HO HO HO HO HO HO HO HO HO",
                     "SECOND",
                     "HA HA HA HA HA HA HA HA HA HA HA HA HA HA HA HA HA HA HA HA HAHA HA HA HA",
                     "LONG THIRD ITEM",
                     "BEFORE FIFTH",
                     "FIFTH"]
        let selectedIndex = 1
        newItemsTextView.text = items.joined(separator: "|")
        newItemsSelectedIndexTextField.text = "\(selectedIndex)"
        tabsControl.set(items: items, selectedItemIndex: selectedIndex)
        allowBounceSwitch.isOn = tabsControl.allowBounce
        allowAlwaysBounceSwitch.isOn = tabsControl.allowAlwaysBounce
        itemsTopMarginTextField.text = "\(tabsControl.itemsTopMargin)"
        itemsBottomMarginTextField.text = "\(tabsControl.itemsBottomMargin)"
        itemLabelHorizontalMarginTextField.text = "\(tabsControl.itemLabelHorizontalMargin)"
        nextItemMinPeakingWidthTextField.text = "\(tabsControl.nextItemMinPeakingWidth)"
        itemNumberOfLinesTextField.text = "\(tabsControl.itemNumberOfLines)"
        itemNumberOfLinesTextField.text = "\(tabsControl.itemNumberOfLines)"
        selectedItemIndexTextField.text = "\(tabsControl.selectedItemIndex)"
        tabsControl.selectionMarkerColor = UIColor.systemBlue
        selectionMarkerHeightTextField.text = "\(tabsControl.selectionMarkerHeight)"
        tabsControl.setTextAttributes(normal: [NSAttributedString.Key.foregroundColor: UIColor.black],
                                      selected: [NSAttributedString.Key.foregroundColor: UIColor.magenta])
    }

    // MARK: - Interface callbacks

    @IBAction private func setItemsButtonDidTap() {
        view.endEditing(true)
        let items = newItemsTextView.text.components(separatedBy: "|").filter({ !$0.isEmpty })
        guard let selectedIndexString = newItemsSelectedIndexTextField.text,
              let selectedIndex = Int(selectedIndexString)
        else {
            return
        }
        tabsControl.set(items: items, selectedItemIndex: selectedIndex)
    }

    @IBAction private func allowBounceSwitchValueDidChange() {
        tabsControl.allowBounce = allowBounceSwitch.isOn
    }

    @IBAction private func allowAlwaysBounceSwitchValueDidChange() {
        tabsControl.allowAlwaysBounce = allowAlwaysBounceSwitch.isOn
    }

    @IBAction private func itemsTopMarginApplyButtonDidTap() {
        view.endEditing(true)
        guard let marginString = itemsTopMarginTextField.text,
              let margin = Int(marginString)
        else {
            return
        }
        self.tabsControl.itemsTopMargin = CGFloat(margin)
        if applyChangesAnimatedSwitch.isOn {
            UIView.animate(withDuration: Constant.defaultAnimationDuration, animations: {
                self.tabsControl.layoutIfNeeded()
            })
        }
    }

    @IBAction private func itemsBottomMarginApplyButtonDidTap() {
        view.endEditing(true)
        guard let marginString = itemsBottomMarginTextField.text,
              let margin = Int(marginString)
        else {
            return
        }
        self.tabsControl.itemsBottomMargin = CGFloat(margin)
        if applyChangesAnimatedSwitch.isOn {
            UIView.animate(withDuration: Constant.defaultAnimationDuration, animations: {
                self.tabsControl.layoutIfNeeded()
            })
        }
    }

    @IBAction private func itemLabelHorizontalMarginApplyButtonDidTap() {
        view.endEditing(true)
        guard let marginString = itemLabelHorizontalMarginTextField.text,
              let margin = Int(marginString)
        else {
            return
        }
        self.tabsControl.itemLabelHorizontalMargin = CGFloat(margin)
        if applyChangesAnimatedSwitch.isOn {
            UIView.animate(withDuration: Constant.defaultAnimationDuration, animations: {
                self.tabsControl.layoutIfNeeded()
            })
        }
    }

    @IBAction private func nextItemMinPeakingWidthApplyButtonDidTap() {
        view.endEditing(true)
        guard let minPeakingString = nextItemMinPeakingWidthTextField.text,
              let minPeaking = Int(minPeakingString)
        else {
            return
        }
        self.tabsControl.nextItemMinPeakingWidth = CGFloat(minPeaking)
        if applyChangesAnimatedSwitch.isOn {
            UIView.animate(withDuration: Constant.defaultAnimationDuration, animations: {
                self.tabsControl.layoutIfNeeded()
            })
        }
    }

    @IBAction private func itemNumberOfLinesApplyButtonDidTap() {
        view.endEditing(true)
        guard let itemNumberOfLinesString = itemNumberOfLinesTextField.text,
              let itemNumberOfLines = Int(itemNumberOfLinesString)
        else {
            return
        }
        self.tabsControl.itemNumberOfLines = itemNumberOfLines
        if applyChangesAnimatedSwitch.isOn {
            UIView.animate(withDuration: Constant.defaultAnimationDuration, animations: {
                self.tabsControl.layoutIfNeeded()
            })
        }
    }

    @IBAction private func selectedItemIndexApplyButtonDidTap() {
        view.endEditing(true)
        guard let selectedIndexString = selectedItemIndexTextField.text,
              let selectedIndex = Int(selectedIndexString)
        else {
            return
        }
        tabsControl.selectedItemIndex = selectedIndex
        if applyChangesAnimatedSwitch.isOn {
            UIView.animate(withDuration: Constant.defaultAnimationDuration, animations: {
                self.tabsControl.layoutIfNeeded()
            })
        }
    }

    @IBAction private func selectionMarkerHeightApplyButtonDidTap() {
        view.endEditing(true)
        guard let heightString = selectionMarkerHeightTextField.text,
              let height = Int(heightString)
        else {
            return
        }
        tabsControl.selectionMarkerHeight = CGFloat(height)
        if applyChangesAnimatedSwitch.isOn {
            UIView.animate(withDuration: Constant.defaultAnimationDuration, animations: {
                self.tabsControl.layoutIfNeeded()
            })
        }
    }

}

// MARK: - ScrollableTabsDelegate

extension ExampleScrollableTabsViewController: ScrollableTabsDelegate {

    internal func scrollableTabs(_ control: ScrollableTabs, didSelectItem itemIndex: Int) {
        print("item selected: \(itemIndex)")
    }

}
