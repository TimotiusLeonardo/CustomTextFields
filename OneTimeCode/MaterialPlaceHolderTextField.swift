//
//  MaterialPlaceHolderTextField.swift
//  OneTimeCode
//
//  Created by Timotius Leonardo Lianoto on 13/12/21.
//

import UIKit

open class MaterialPlaceHolderTextField: UITextField {
    
    enum TextFieldEditingState {
        case editing
        case notEditing
    }
    
    enum TextFieldStatusState {
        case error
        case warning
        case normal
        
        var baseColor: UIColor {
            switch self {
            case .error:
                return UIColor.red
            case .warning:
                return UIColor.yellow
            case .normal:
                return UIColor.black
            }
        }
    }
    
    fileprivate var lmd_state : TextFieldEditingState = .notEditing {
        didSet {
            self.animatePlaceholderIfNeeded(with: lmd_state)
        }
    }
    
    fileprivate var lmd_status_state : TextFieldStatusState = .normal {
        didSet {
            toggleBaseColor()
            setNeedsLayout()
        }
    }
    
    fileprivate weak var lmd_placeholder: UILabel!
    fileprivate let textRectYInset : CGFloat = 7
    fileprivate var editingConstraints = [NSLayoutConstraint]()
    fileprivate var notEditingConstraints : [NSLayoutConstraint]!
    fileprivate var activeConstraints : [NSLayoutConstraint]!
    
    fileprivate lazy var hintLabel: UILabel? = {
        let label = UILabel()
        return label
    }()
    
    //MARK: - PUBLIC VARIABLES
    public var placeholderFont = UIFont.systemFont(ofSize: 14) {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    open override var text: String? {
        didSet {
            self.animatePlaceholderIfNeeded(with: self.lmd_state)
        }
    }
    
    @IBInspectable public var placeholderText: String? {
        didSet {
            self.lmd_placeholder.text = placeholderText
            self.animatePlaceholderIfNeeded(with: self.lmd_state)
        }
    }
    
    @IBInspectable public  var placeholderSizeFactor: CGFloat = 0.7  {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable public  var themeColor: UIColor? = .black {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable public  var borderColor: UIColor? = UIColor(white: 74/255, alpha: 1) {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable public  var errorBorderColor: UIColor? = UIColor(red: 1, green: 0, blue: 131/255, alpha: 1) {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable public var placeholderTextColor: UIColor = UIColor(white: 183/255, alpha: 1) {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable public var textFieldTextColor: UIColor = UIColor(white: 74/255, alpha: 1) {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable public var disabledTextColor: UIColor = UIColor(white: 183/255, alpha: 1) {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable public var disabledBackgroundColor: UIColor = UIColor(white: 247/255, alpha: 1) {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable public var enabledBackgroundColor: UIColor = .white {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    public var disabled = false {
        didSet {
            self.updateState(.notEditing)
        }
    }
    
    @IBInspectable public var topPadding: CGFloat = 6
    @IBInspectable public var leftPadding: CGFloat = 14
    
    //MARK: - LIFE CYCLE
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupViews()
    }
    
    fileprivate func setupViews() {
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 2
        
        self.addTarget(self, action: #selector(editingDidBegin), for: UIControl.Event.editingDidBegin)
        self.addTarget(self, action: #selector(editingDidEnd), for: UIControl.Event.editingDidEnd)
        
        let placeholder = UILabel()
        
        placeholder.layoutMargins = .zero
        placeholder.translatesAutoresizingMaskIntoConstraints = false
        placeholder.insetsLayoutMarginsFromSafeArea = false
        self.addSubview(placeholder)
        
        self.lmd_placeholder = placeholder
        
        self.notEditingConstraints = [
            NSLayoutConstraint(item: self.lmd_placeholder ?? UILabel(), attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: self.leftPadding),
            NSLayoutConstraint(item: self.lmd_placeholder ?? UILabel(), attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
        ]
        NSLayoutConstraint.activate(self.notEditingConstraints)
        self.activeConstraints = self.notEditingConstraints
        self.setNeedsLayout()
    }
    
    fileprivate func calculateEditingConstraints() {
        let attributedStringPlaceholder = NSAttributedString(string: (self.placeholderText ?? "").uppercased(), attributes: [
            NSAttributedString.Key.font : self.placeholderFont
            ])
        let originalWidth = attributedStringPlaceholder.boundingRect(with: CGSize(width: .greatestFiniteMagnitude, height: self.frame.height), options: [], context: nil).width
        
        let xOffset = (originalWidth - (originalWidth * placeholderSizeFactor)) / 2
        
        self.editingConstraints = [
            NSLayoutConstraint(item: self.lmd_placeholder ?? UILabel(), attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: -xOffset + self.leftPadding),
            NSLayoutConstraint(item: self.lmd_placeholder ?? UILabel(), attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: self.topPadding)
        ]
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        UIView.animate(withDuration: 0.2) {
            self.lmd_placeholder.font = self.placeholderFont
            self.lmd_placeholder.textColor = self.placeholderTextColor
            self.lmd_placeholder.text = self.placeholderText
            self.textColor = self.disabled ? self.disabledTextColor : self.textFieldTextColor
            self.backgroundColor = self.disabled ? self.disabledBackgroundColor : self.enabledBackgroundColor
            self.layer.borderColor = self.lmd_status_state != .normal ? self.lmd_status_state.baseColor.cgColor :
                                     self.lmd_state == .editing ? self.borderColor?.cgColor : UIColor(white: 236/255, alpha: 1).cgColor
        }
        self.tintColor = themeColor
        self.isEnabled = !self.disabled
    }
    
    fileprivate func animatePlaceholderIfNeeded(with state: TextFieldEditingState) {
        
        switch state {
        case .editing:
            self.animatePlaceholderToActivePosition()
        case .notEditing:
            if (self.text ?? "").isEmpty {
                self.animatePlaceholderToInactivePosition()
            } else {
                self.animatePlaceholderToActivePosition()
            }
        }
        self.setNeedsLayout()
    }
    
    fileprivate func animatePlaceholderToActivePosition(animated: Bool = true) {
        self.calculateEditingConstraints()
        self.layoutIfNeeded()
        NSLayoutConstraint.deactivate(self.activeConstraints)
        NSLayoutConstraint.activate(self.editingConstraints)
        self.activeConstraints = self.editingConstraints
        
        let animationBlock = {
            self.layoutIfNeeded()
            self.lmd_placeholder.transform = CGAffineTransform(scaleX: self.placeholderSizeFactor, y: self.placeholderSizeFactor)
        }
        if animated {
            UIView.animate(withDuration: 0.2) {
                animationBlock()
            }
        } else {
            animationBlock()
        }
    }
    
    private func toggleBaseColor() {
        self.placeholderTextColor = lmd_status_state.baseColor
    }
    
    fileprivate func animatePlaceholderToInactivePosition(animated: Bool = true) {
        self.layoutIfNeeded()
        NSLayoutConstraint.deactivate(self.activeConstraints)
        NSLayoutConstraint.activate(self.notEditingConstraints)
        self.activeConstraints = self.notEditingConstraints
        let animationBlock = {
            self.layoutIfNeeded()
            self.lmd_placeholder.transform = .identity
        }
        if animated {
            UIView.animate(withDuration: 0.2) {
                animationBlock()
            }
        } else {
            animationBlock()
        }
    }
    
    @objc private func editingDidBegin() {
        self.lmd_state = .editing
    }
    
    @objc private func editingDidEnd() {
        self.lmd_state = .notEditing
    }
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        super.textRect(forBounds: bounds)
        return self.calculateTextRect(forBounds: bounds)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        super.textRect(forBounds: bounds)
        return self.calculateTextRect(forBounds: bounds)
    }
    
    fileprivate func calculateTextRect(forBounds bounds: CGRect) -> CGRect {
        let textInset = (self.placeholderText ?? "").isEmpty == true ? 0 : self.textRectYInset
        return CGRect(x: leftPadding,
                      y: textInset,
                      width: bounds.width - (leftPadding * 2),
                      height: bounds.height)
    }
    
    //MARK: - PUBLIC FUNCTIONS
    func updateState(_ state: TextFieldEditingState) {
        self.lmd_state = state
    }
    
    func updateStatusState(_ state: TextFieldStatusState) {
        self.lmd_status_state = state
    }
}
