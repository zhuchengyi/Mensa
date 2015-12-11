//
//  Label.swift
//  Mensa
//
//  Created by Jordan Kay on 7/28/15.
//  Copyright © 2015 Tangible. All rights reserved.
//

import UIKit

@IBDesignable public class Label: UILabel {
    @IBInspectable var lineHeight: CGFloat = 1.0 {
        didSet {
            updateLineHeight()
        }
    }
    
    @IBInspectable var letterSpacing: CGFloat = 1.0 {
        didSet {
            updateLetterSpacing()
        }
    }
    
    // MARK: NSObject
    override public func awakeFromNib() {
        lineBreakMode = .ByWordWrapping
    }
    
    // MARK: UIView
    override public var bounds: CGRect {
        didSet {
            preferredMaxLayoutWidth = CGRectGetWidth(bounds)
        }
    }
    
    // MARK: UILabel
    override public var text: String? {
        didSet {
            updateLineHeight()
            updateLetterSpacing()
        }
    }
}

private extension Label {
    func updateLineHeight() {
        if let text = text, attributedText = attributedText {
            let string = NSMutableAttributedString(attributedString: attributedText)
            let range = NSRange(location: 0, length: (text as NSString).length)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = textAlignment
            paragraphStyle.lineSpacing = lineHeight
            string.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: range)
            self.attributedText = string
        }
    }
    
    func updateLetterSpacing() {
        if let text = text, attributedText = attributedText {
            let string = NSMutableAttributedString(attributedString: attributedText)
            let range = NSRange(location: 0, length: (text as NSString).length)
            string.addAttribute(NSKernAttributeName, value: letterSpacing, range: range)
            self.attributedText = string
        }
    }
}
