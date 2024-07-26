//
//  DineTextFieldInternal.swift
//  Dine
//
//  Created by doss-zstch1212 on 25/07/24.
//
// Credits to Team Microsoft
// https://github.com/microsoft/fluentui-apple

import UIKit

/// Internal subclass of UITextField that allows us to adjust the position of the `rightView`.
class DineTextFieldInternal: UITextField {
    init() {
        super.init(frame: .zero)
        
        clearButton.addTarget(self, action: #selector(clearText), for: .touchUpInside)
        rightView = clearButton
        rightViewMode = .whileEditing
        
        adjustsFontForContentSizeCategory = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        let origin = super.rightViewRect(forBounds: bounds).origin
        return CGRect(x: origin.x - trailingViewSpacing, y: origin.y, width: trailingViewSize, height: trailingViewSize)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.editingRect(forBounds: bounds)
        let origin = rect.origin
        let size = rect.size
        return CGRect(x: origin.x, y: origin.y, width: size.width - (trailingViewSpacing + inputTextTrailingIconSpacing), height: size.height)
    }
    
    let trailingViewSpacing: CGFloat = 8.0
    let inputTextTrailingIconSpacing: CGFloat = 4.0
    let trailingViewSize: CGFloat = 20.0
    var clearButton: UIButton = {
        let button = UIButton()
        let clearSFSymbol = UIImage(systemName: "multiply.circle.fill")
        button.setImage(clearSFSymbol, for: .normal)
        button.tintColor = .secondaryLabel
        return button
    }()
    
    override var text: String? {
        didSet {
            guard let validateInputText else {
                return
            }
            validateInputText()
        }
    }
    
    @objc private func clearText() {
        text = nil
        rightViewMode = .whileEditing
    }
    
    var validateInputText: (() -> Void)?
}
