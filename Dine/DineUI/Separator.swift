//
//  Separator.swift
//  Dine
//
//  Created by doss-zstch1212 on 25/07/24.
//

import UIKit

// MARK: - SeparatorOrientation

@objc enum SeparatorOrientation: Int {
    case horizontal
    case vertical
}

// MARK: - Separator

@objc class Separator: UIView {
    private var orientation: SeparatorOrientation = .horizontal
    
    @objc override init(frame: CGRect) {
        super.init(frame: frame)
        initialize(orientation: .horizontal)
    }
    
    @objc init(orientation: SeparatorOrientation = .horizontal) {
        super.init(frame: .zero)
        initialize(orientation: orientation)
    }
    
    required init?(coder aDecoder: NSCoder) {
        preconditionFailure("init(coder:) has not been implemented")
    }
    
    /**
     The default thickness for the separator: half pt.
    */
    @objc static var thickness: CGFloat { return 0.5 }
    
    @objc static func separatorDefaultColor() -> UIColor {
        return UIColor.lightGray
    }
    
    private func initialize(orientation: SeparatorOrientation) {
        backgroundColor = Separator.separatorDefaultColor()
        self.orientation = orientation
        switch orientation {
        case .horizontal:
            frame.size.height = Separator.thickness
            autoresizingMask = .flexibleWidth
        case .vertical:
            frame.size.width = Separator.thickness
            autoresizingMask = .flexibleHeight
        }
        isAccessibilityElement = false
        isUserInteractionEnabled = false
    }
    
    override var intrinsicContentSize: CGSize {
        switch orientation {
        case .horizontal:
            return CGSize(width: UIView.noIntrinsicMetric, height: frame.height)
        case .vertical:
            return CGSize(width: frame.width, height: UIView.noIntrinsicMetric)
        }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        switch orientation {
        case .horizontal:
            return CGSize(width: size.width, height: frame.height)
        case .vertical:
            return CGSize(width: frame.width, height: size.height)
        }
    }
}
