//
//  MaterialTextView.swift
//  OneTimeCode
//
//  Created by Timotius Leonardo Lianoto on 24/02/22.
//

import UIKit

protocol MaterialTextViewDelegate: AnyObject {
    func didChangeValue(_ textView: MaterialTextView)
    func didBeginEditing(_ textView: MaterialTextView)
    func didEndEditing(_ textView: MaterialTextView)
    func didTapRightButton(_ textView: MaterialTextView)
}

extension MaterialTextViewDelegate {
    func didChangeValue(_ textView: MaterialTextView) {
        print(textView.text ?? "no text")
    }
    
    func didBeginEditing(_ textView: MaterialTextView) {
        print(textView.text ?? "no text")
    }
    
    func didEndEditing(_ textView: MaterialTextView) {
        print(textView.text ?? "no text")
    }
    
    func didTapRightButton(_ textView: MaterialTextView) {
        print(textView.text ?? "no text")
    }
}

class MaterialTextView: UITextView {
    
    enum TextFieldEditingState {
        case editing
        case notEditing
    }
    
    enum TextFieldStatusState {
        case error
        case warning
        case normal
    }
    
    fileprivate var lmd_state: TextFieldEditingState = .notEditing {
        didSet {
            self.compileEditingStyle()
            self.animatePlaceholderIfNeeded(with: lmd_state)
        }
    }
    
    private (set) var lmd_status_state: TextFieldStatusState = .normal {
        didSet {
            setNeedsLayout()
        }
    }
    
    fileprivate weak var lmd_placeholder: UILabel!
    fileprivate let textRectYInset: CGFloat = 7
    fileprivate var editingConstraints = [NSLayoutConstraint]()
    fileprivate var notEditingConstraints = [NSLayoutConstraint]()
    fileprivate var activeConstraints = [NSLayoutConstraint]()
//    private var editActions: [IDNMaterialTextField.ResponderStandardEditActions: Bool]?
//    private var filterEditActions: [IDNMaterialTextField.ResponderStandardEditActions: Bool]?
    
    private lazy var rightButton: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        let tapHandler = UITapGestureRecognizer(target: self, action: #selector(didTapRightButton))
        imageView.addGestureRecognizer(tapHandler)
        return imageView
    }()
    
    private var _baseColor: UIColor {
        switch lmd_status_state {
        case .error:
            return .red // IDNColor.ottomanRed
        case .warning:
            return .yellow // IDNColor.editorTooltip
        case .normal:
            return .black // baseColor ?? IDNColor.blackLead
        }
    }
    
    private var _placeholderColor: UIColor {
        switch lmd_status_state {
        case .error:
            return .red // errorPlaceholderTextColor ?? IDNColor.ottomanRed
        case .warning:
            return .yellow // IDNColor.editorTooltip
        case .normal:
            return .black // placeholderTextColor ?? IDNColor.silverCharm
        }
    }
    
    private var _alternativePlaceholderColor: UIColor {
        switch lmd_status_state {
        case .error:
            return .red // errorAlternativePlaceholderColor ?? IDNColor.ottomanRed
        case .warning:
            return .yellow // IDNColor.editorTooltip
        case .normal:
            return .black // alternativePlaceholderColor ?? IDNColor.tarnishedSilver
        }
    }
    
    private var buttonConstraints = [NSLayoutConstraint]()
    
    // MARK: - PUBLIC VARIABLES
    var callback: ((String?, UITextField) -> Void)?
    weak var mtv_textFieldDelegate: MaterialTextViewDelegate?
    
    var placeholderFont = UIFont.systemFont(ofSize: 14, weight: .regular)  /* IDNFont.make(size: 14, weight: .regular) */ {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    open override var text: String? {
        didSet {
            self.animatePlaceholderIfNeeded(with: self.lmd_state)
        }
    }
    
    @IBInspectable var placeholderText: String? {
        didSet {
            self.lmd_placeholder.text = placeholderText
            self.animatePlaceholderIfNeeded(with: self.lmd_state)
        }
    }
    
    @IBInspectable var placeholderSizeFactor: CGFloat = 0.7 {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable var themeColor: UIColor? = .black {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable var baseColor: UIColor? {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable var placeholderTextColor: UIColor? {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable var alternativePlaceholderColor: UIColor? {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable var errorPlaceholderTextColor: UIColor? {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable var errorAlternativePlaceholderColor: UIColor? {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable var textFieldTextColor: UIColor = .black /* IDNColor.darkWillow */ {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable var disabledTextColor: UIColor = .lightGray /* IDNColor.silverCharm */ {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable var disabledBackgroundColor: UIColor =  .brown /* IDNColor.callaLily */ {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable var enabledBackgroundColor: UIColor = .white /* IDNColor.flashWhite */ {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable var onEditingBorderColor: UIColor = .red /* IDNColor.ottomanRed */ {
        didSet {
            //
        }
    }
    
    @IBInspectable var onEditingBorderWidth: CGFloat = 1 {
        didSet {
            //
        }
    }
    
    @IBInspectable var onNotEditingBorderColor: UIColor = .clear {
        didSet {
            //
        }
    }
    
    @IBInspectable var rightButtonTintColor: UIColor? {
        didSet {
            rightButton.tintColor = rightButtonTintColor
        }
    }
    
    @IBInspectable var onNotEditingBorderWidth: CGFloat = 0 {
        didSet {
            //
        }
    }
    
    @IBInspectable var _borderWidth: CGFloat = 1 {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable var _cornerRadius: CGFloat = 5 {
        didSet {
            self.setNeedsLayout()
        }
    }
    
//    @IBInspectable var hintFont: UIFont = .systemFont(ofSize: 11, weight: .regular) /* IDNFont.make(size: 11, weight: .regular) */ {
//        didSet {
//            hintLabel.font = hintFont
//        }
//    }
//    
//    @IBInspectable var hintNumberOfLines: Int = 2 {
//        didSet {
//            hintLabel.numberOfLines = hintNumberOfLines
//        }
//    }
    
    var disabled = false {
        didSet {
            self.updateState(.notEditing)
        }
    }
    
    @IBInspectable var topPadding: CGFloat = 6 {
        didSet {
            updatePlaceholderConstraints()
        }
    }
    
    @IBInspectable var leftPadding: CGFloat = 16 {
        didSet {
            updatePlaceholderConstraints()
        }
    }
    
//    @IBInspectable var hintLabelPadding: UIEdgeInsets = .init(top: 4, left: 16, bottom: 0, right: 16) {
//        didSet {
//            self.setNeedsLayout()
//        }
//    }
    
    @IBInspectable public var rightButtonWidth: CGFloat = 24 {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable public var rightButtonHeight: CGFloat = 24 {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable public var rightViewImage: UIImage? {
        didSet {
            rightButton.image = self.rightViewImage
            rightButton.isHidden = rightViewImage == nil
            setNeedsLayout()
        }
    }
    
    open override var autocapitalizationType: UITextAutocapitalizationType {
        didSet {
            //
        }
    }
    
    // MARK: - LIFE CYCLE
    override public init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        self.setupViews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupViews()
    }
    
    private func setupViews() {
        rightButton.isHidden = true
        textContainerInset = calculateTextContainerInset()
        delegate = self
        let placeholder = UILabel()
        placeholder.layoutMargins = .zero
        placeholder.translatesAutoresizingMaskIntoConstraints = false
        placeholder.insetsLayoutMarginsFromSafeArea = false
        
        addSubview(placeholder)
        addSubview(rightButton)
        
        self.buttonConstraints = [
            rightButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            rightButton.heightAnchor.constraint(equalToConstant: rightButtonHeight),
            rightButton.widthAnchor.constraint(equalToConstant: rightButtonWidth),
            rightButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ]
        
        self.lmd_placeholder = placeholder
        
        self.notEditingConstraints = [
            NSLayoutConstraint(item: self.lmd_placeholder ?? UILabel(),
                               attribute: .left,
                               relatedBy: .equal,
                               toItem: self,
                               attribute: .left,
                               multiplier: 1,
                               constant: self.leftPadding),
            NSLayoutConstraint(item: self.lmd_placeholder ?? UILabel(),
                               attribute: .top,
                               relatedBy: .equal,
                               toItem: self,
                               attribute: .top,
                               multiplier: 1,
                               constant: self.topPadding + 20)
        ]
        
        NSLayoutConstraint.activate(self.notEditingConstraints)
        NSLayoutConstraint.activate(self.buttonConstraints)
        
        self.activeConstraints = self.notEditingConstraints
        self.setNeedsLayout()
    }
    
    private func compileEditingStyle() {
        if lmd_state == .editing {
            self.layer.borderColor = self.onEditingBorderColor.cgColor
            self._borderWidth = self.onEditingBorderWidth
        } else {
            self.layer.borderColor = self.onNotEditingBorderColor.cgColor
            self._borderWidth = self.onNotEditingBorderWidth
        }
    }
    
    private func calculateEditingConstraints() {
        let attributedStringPlaceholder = NSAttributedString(string: (self.placeholderText ?? ""), attributes: [
            NSAttributedString.Key.font: self.placeholderFont
        ])
        let originalWidth = attributedStringPlaceholder.boundingRect(with: CGSize(width: .greatestFiniteMagnitude, height: self.frame.height),
                                                                     options: [],
                                                                     context: nil).width
        
        let xOffset = (originalWidth - (originalWidth * placeholderSizeFactor)) / 2
        
        self.editingConstraints = [
            NSLayoutConstraint(item: self.lmd_placeholder ?? UILabel(),
                               attribute: .left,
                               relatedBy: .equal,
                               toItem: self,
                               attribute: .left,
                               multiplier: 1,
                               constant: -xOffset + self.leftPadding),
            NSLayoutConstraint(item: self.lmd_placeholder ?? UILabel(),
                               attribute: .top,
                               relatedBy: .equal,
                               toItem: self,
                               attribute: .top,
                               multiplier: 1,
                               constant: self.topPadding)
        ]
    }
    
    private func updatePlaceholderConstraints() {
        NSLayoutConstraint.deactivate(notEditingConstraints)
        notEditingConstraints = [
            NSLayoutConstraint(item: self.lmd_placeholder ?? UILabel(),
                               attribute: .left,
                               relatedBy: .equal,
                               toItem: self,
                               attribute: .left,
                               multiplier: 1,
                               constant: self.leftPadding),
            NSLayoutConstraint(item: self.lmd_placeholder ?? UILabel(),
                               attribute: .top,
                               relatedBy: .equal,
                               toItem: self,
                               attribute: .top,
                               multiplier: 1,
                               constant: self.topPadding + 20)
        ]
        NSLayoutConstraint.activate(notEditingConstraints)
        textContainerInset = calculateTextContainerInset()
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = _cornerRadius
        self.layer.borderWidth = _borderWidth
        
        NSLayoutConstraint.deactivate(self.buttonConstraints)
        
        self.buttonConstraints = [
            rightButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            rightButton.heightAnchor.constraint(equalToConstant: rightButtonHeight),
            rightButton.widthAnchor.constraint(equalToConstant: rightButtonWidth),
            rightButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ]
        
        NSLayoutConstraint.activate(self.buttonConstraints)
        
        UIView.transition(with: lmd_placeholder, duration: 0.25, options: .transitionCrossDissolve) {
            switch self.lmd_state {
            case .editing:
                self.lmd_placeholder.textColor = self._alternativePlaceholderColor
            case .notEditing:
                if (self.text ?? "").isEmpty {
                    self.lmd_placeholder.textColor = self._placeholderColor
                } else {
                    self.lmd_placeholder.textColor = self._alternativePlaceholderColor
                }
            }
            self.lmd_placeholder.font = self.placeholderFont
            self.lmd_placeholder.text = self.placeholderText
            self.textColor = self.disabled ? self.disabledTextColor : self.textFieldTextColor
            self.backgroundColor = self.disabled ? self.disabledBackgroundColor : self.enabledBackgroundColor
        }
        
        self.tintColor = themeColor
        self.isEditable = !self.disabled
    }
    
//    func setEditActions(only actions: [IDNMaterialTextField.ResponderStandardEditActions]) {
//        if self.editActions == nil { self.editActions = [:] }
//        filterEditActions = nil
//        actions.forEach { self.editActions?[$0] = true }
//    }
//
//    func addToCurrentEditActions(actions: [IDNMaterialTextField.ResponderStandardEditActions]) {
//        if self.filterEditActions == nil { self.filterEditActions = [:] }
//        editActions = nil
//        actions.forEach { self.filterEditActions?[$0] = true }
//    }
//
//    private func filterEditActions(actions: [IDNMaterialTextField.ResponderStandardEditActions], allowed: Bool) {
//        if self.filterEditActions == nil { self.filterEditActions = [:] }
//        editActions = nil
//        actions.forEach { self.filterEditActions?[$0] = allowed }
//    }
//
//    func filterEditActions(notAllowed: [IDNMaterialTextField.ResponderStandardEditActions]) {
//        filterEditActions(actions: notAllowed, allowed: false)
//    }
//
//    func resetEditActions() { editActions = nil }
//
//    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
//        if let actions = editActions {
//            for _action in actions where _action.key.selector == action { return _action.value }
//            return false
//        }
//
//        if let actions = filterEditActions {
//            for _action in actions where _action.key.selector == action { return _action.value }
//        }
//
//        return super.canPerformAction(action, withSender: sender)
//    }
    
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
            self.lmd_placeholder.textColor = self.lmd_status_state == .normal ? UIColor.yellow : self.placeholderTextColor
        }
        if animated {
            UIView.animate(withDuration: 0.2) {
                animationBlock()
            }
        } else {
            animationBlock()
        }
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
    
    private func editingDidBegin() {
        self.lmd_state = .editing
    }
    
    private func editingDidEnd() {
        self.lmd_state = .notEditing
    }
    
    @objc private func didTapRightButton() {
        mtv_textFieldDelegate?.didTapRightButton(self)
    }
    
    fileprivate func calculateTextContainerInset() -> UIEdgeInsets {
        return .init(top: 20 + topPadding, left: leftPadding - 5, bottom: 20, right: leftPadding - 5)
    }
    
//    private func animateHintLabelShow(_ message: String?) {
//        UIView.transition(with: hintLabel, duration: 0.2, options: .transitionCrossDissolve, animations: {
//            self.hintLabel.text = message
//
//            if self.lmd_status_state == .normal {
//                self.compileEditingStyle()
//            } else {
//                self.layer.borderColor = self._baseColor.cgColor
//            }
//        }, completion: nil)
//    }
    
    // MARK: - PUBLIC FUNCTIONS
    /// Update editing state of material textfield
    func updateState(_ state: TextFieldEditingState) {
        self.lmd_state = state
    }
    /// Change Status State (.normal, .error, .warning) to a textfield, Assign message if you want to show HINT, and also give border width if you want to
    func updateStatusState(_ state: TextFieldStatusState, message: String?, borderWidth: CGFloat = 0) {
        self.lmd_status_state = state
        _borderWidth = borderWidth
    }
}

extension MaterialTextView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        editingDidBegin()
        mtv_textFieldDelegate?.didBeginEditing(self)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        editingDidEnd()
        mtv_textFieldDelegate?.didEndEditing(self)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        mtv_textFieldDelegate?.didChangeValue(self)
    }
    
}
