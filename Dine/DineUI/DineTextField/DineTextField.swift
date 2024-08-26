//
//  DineTextField.swift
//  Dine
//
//  Created by doss-zstch1212 on 24/07/24.
//

/// https://github.com/microsoft/fluentui-apple
///     - credits to microsoft

import UIKit

/// The predefined states of the `DineTextField`.
public enum DineTextFieldState: Int, CaseIterable {
    case unfocused
    case focused
    case error
}

final class DineTextField: UIView, UITextFieldDelegate {
    /// UIImage used in the leading UIImageView. If this is nil, the leading UIImageView will be hidden.
    public var leadingImage: UIImage? {
        didSet {
            if let leadingImage {
                leadingImageView.image = leadingImage
                leadingImageContainerView.isHidden = false
            } else {
                leadingImageContainerView.isHidden = true
            }
        }
    }
    
    /// String used in the title label. If this is nil, the title label will be hidden.
    public var titleText: String? {
        didSet {
            if let titleText {
                titleLabel.text = titleText
                titleLabel.isHidden = false
            } else {
                titleLabel.isHidden = true
            }
        }
    }
    
    /// String representing the input text.
    public var inputText: String? {
        get {
            return textfield.text
        }
        set {
            textfield.text = newValue
        }
    }
    
    public var keyboardType: UIKeyboardType {
        get {
            return textfield.keyboardType
        }
        set {
            textfield.keyboardType = newValue
        }
    }
    
    /// String representing the placeholder text.
    public var placeholder: String? {
        didSet {
            textfield.attributedPlaceholder = attributedPlaceholder
        }
    }
    
    /// String used in the assistive text label. If this is nil, the assistive text label will be hidden. If the `error`
    /// property of the `FluentTextField` is set, the `localizedDescription` from `error`
    /// will be displayed instead.
    public var assitiveText: String? {
        didSet {
            updateAssistiveText()
        }
    }
    /// The closure for the action to be called in response to the textfield's `.editingChanged` event.
    @objc public var onEditingChanged: ((DineTextField) -> Void)?

    /// The closure for the action to be called in `textFieldDidBeginEditing`.
    @objc public var onDidBeginEditing: ((DineTextField) -> Void)?

    /// The closure for the action to be called in `textFieldDidEndEditing`.
    @objc public var onDidEndEditing: ((DineTextField) -> Void)?

    /// The closure for the action to be called in `textFieldShouldReturn`. The return value of `onReturn`
    /// will be returned in `textFieldShouldReturn`.
    @objc public var onReturn: ((DineTextField) -> Bool)?
    
    /// The `FluentTextInputError` containing the `localizedDescription` that will be
    /// displayed in the assistive text label.
    public var error: DineTextInputError? {
        didSet {
            updateState()
            updateAssistiveText()
        }
    }
    
    public override var canBecomeFirstResponder: Bool {
        textfield.canBecomeFirstResponder
    }
    
    // Hierarchy:
    //
    // imageTextStack
    // |--leadingImageContainerView
    // |--|--leadingImageView
    // |--textStack
    // |--|--titleLabel
    // |--|--textfield
    // |--|--separator
    // |--|--assistiveTextLabel
    public override init(frame: CGRect) {
        super.init(frame: frame)
        textfield.validateInputText = editingChanged
        textfield.delegate = self
        textfield.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        
        let textStack = UIStackView(arrangedSubviews: [titleLabel, textfield, separator, assistiveTextLabel])
        textStack.axis = .vertical
        textStack.spacing = 12
        textStack.setCustomSpacing(4, after: separator)
        textStack.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: 12,
            leading: 0,
            bottom: 4,
            trailing: 0
        )
        
        textStack.isLayoutMarginsRelativeArrangement = true
        
        leadingImageContainerView.addSubview(leadingImageView)
        
        let imageTextStack = UIStackView(arrangedSubviews: [leadingImageContainerView, textStack])
        imageTextStack.spacing = 16
        imageTextStack.translatesAutoresizingMaskIntoConstraints = false
        imageTextStack.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: 0,
            leading: 8,
            bottom: 0,
            trailing: 8
        )
        imageTextStack.isLayoutMarginsRelativeArrangement = true
        
        addSubview(imageTextStack)
        
        let safeArea = safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            separator.widthAnchor.constraint(equalTo: textStack.widthAnchor),
            textfield.leadingAnchor.constraint(equalTo: textStack.leadingAnchor),
            textfield.trailingAnchor.constraint(equalTo: textStack.trailingAnchor),
            imageTextStack.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            imageTextStack.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            imageTextStack.topAnchor.constraint(equalTo: safeArea.topAnchor),
            imageTextStack.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            leadingImageContainerView.leadingAnchor.constraint(equalTo: leadingImageView.leadingAnchor),
            leadingImageContainerView.trailingAnchor.constraint(equalTo: leadingImageView.trailingAnchor),
            leadingImageView.centerYAnchor.constraint(equalTo: textfield.centerYAnchor)
        ])
    }
    
    @discardableResult
    public override func becomeFirstResponder() -> Bool {
        let didBecomeFirstResponder = textfield.becomeFirstResponder()
        updateState()
        return didBecomeFirstResponder
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UITextFieldDelegate
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        if let onDidBeginEditing {
            onDidBeginEditing(self)
        }
        updateState()
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        if let onDidEndEditing {
            onDidEndEditing(self)
        }
        updateState()
        if inputText?.isEmpty == true {
            textField.rightViewMode = .whileEditing
        } else {
            textField.rightViewMode = .always
        }
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let onReturn {
            return onReturn(self)
        }
        return true
    }
    
    var attributedPlaceholder: NSAttributedString? {
        guard let placeholder else {
            return nil
        }
        return NSAttributedString(string: placeholder, attributes: [.foregroundColor: UIColor.secondaryLabel])
    }
    
    // The leadingImageView needs a container to be vertically centered on the
    // textfield
    let leadingImageContainerView: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()
    
    let leadingImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        imageView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .label
        return label
    }()
    
    let textfield: DineTextFieldInternal = {
        let field = DineTextFieldInternal()
        field.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return field
    }()
    
    let separator: Separator = {
        let separator = Separator()
        return separator
    }()
    
    let assistiveTextLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.lineBreakMode = .byWordWrapping
        label.textColor = .systemRed
        label.font = .preferredFont(forTextStyle: .footnote)
        label.numberOfLines = 0
        return label
    }()
    
    @objc private func editingChanged() {
        guard let onEditingChanged else {
            return
        }
        onEditingChanged(self)
    }
    
    private func updateState() {
        if error != nil {
            state = .error
        } else {
            state = textfield.isFirstResponder ? .focused : .unfocused
        }
    }
    
    private func updateAssistiveText() {
        if let error {
            assistiveTextLabel.text = error.localizedDescription
            assistiveTextLabel.isHidden = false
        } else if let assitiveText {
            assistiveTextLabel.text = assitiveText
            assistiveTextLabel.isHidden = false
        } else {
            assistiveTextLabel.text = nil
            assistiveTextLabel.isHidden = true
        }
    }
    
    private var state: DineTextFieldState = .unfocused
}

