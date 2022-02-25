//
//  IDNMaterialTextView.swift
//  OneTimeCode
//
//  Created by Timotius Leonardo Lianoto on 24/02/22.
//

import UIKit

class IDNMaterialTextView: UIView {
    // MARK: - Components
    private lazy var hintLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = hintFont
        label.numberOfLines = hintNumberOfLines
        return label
    }()
    
    private (set) lazy var materialTextView: MaterialTextView = {
        let textView = MaterialTextView()
        textView.placeholderText = "Enter message here"
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    // MARK: - Variables
    @IBInspectable var hintFont: UIFont = .systemFont(ofSize: 11, weight: .regular) /* IDNFont.make(size: 11, weight: .regular) */ {
        didSet {
            hintLabel.font = hintFont
        }
    }
    
    @IBInspectable var hintNumberOfLines: Int = 2 {
        didSet {
            hintLabel.numberOfLines = hintNumberOfLines
        }
    }
    
    @IBInspectable var hintMessage: String? {
        didSet {
            animateHintLabelShow(hintMessage)
        }
    }
    
    @IBInspectable var hintLabelPadding: UIEdgeInsets = .init(top: 4, left: 16, bottom: 0, right: 16) {
        didSet {
            self.setNeedsUpdateConstraints()
        }
    }
    
    var hintLabelConstraints = [NSLayoutConstraint]()
    var materialTextFieldConstraints = [NSLayoutConstraint]()
    
    // MARK: - Functions
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        [hintLabel, materialTextView].forEach { subview in
            addSubview(subview)
        }
        setNeedsUpdateConstraints()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let materialTextViewBorderColor = materialTextView.layer.borderColor {
            hintLabel.textColor = UIColor(cgColor: materialTextViewBorderColor)
        }
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        
        NSLayoutConstraint.deactivate(hintLabelConstraints)
        NSLayoutConstraint.deactivate(materialTextFieldConstraints)
        
        hintLabelConstraints = [
            hintLabel.topAnchor.constraint(equalTo: materialTextView.bottomAnchor, constant: hintLabelPadding.top),
            hintLabel.leadingAnchor.constraint(equalTo: materialTextView.leadingAnchor, constant: hintLabelPadding.left),
            hintLabel.trailingAnchor.constraint(equalTo: materialTextView.trailingAnchor, constant: hintLabelPadding.right),
            hintLabel.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.1)
        ]
        
        materialTextFieldConstraints = [
            materialTextView.topAnchor.constraint(equalTo: topAnchor),
            materialTextView.leadingAnchor.constraint(equalTo: leadingAnchor),
            materialTextView.trailingAnchor.constraint(equalTo: trailingAnchor),
            materialTextView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.9)
        ]
        
        NSLayoutConstraint.activate(hintLabelConstraints)
        NSLayoutConstraint.activate(materialTextFieldConstraints)
    }
    
    private func animateHintLabelShow(_ message: String?) {
        UIView.transition(with: hintLabel, duration: 0.2, options: .transitionCrossDissolve, animations: {
            self.hintLabel.text = message
            self.setNeedsLayout()
        }, completion: nil)
    }
}
