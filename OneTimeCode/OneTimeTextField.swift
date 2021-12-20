//
//  OneTimeCodeTextField.swift
//  OneTimeCode
//
//  Created by Timotius Leonardo Lianoto on 08/12/21.
//

import UIKit

class OneTimeTextField: UITextField {
    
    var didEnterLastDigit: ((String) -> Void)?

    private var isConfigured = false
    private var digitLabels = [UILabel]()
    private var cursors = [UIView]()
    var defaultCharacter = ""
    private lazy var tapRecognizer: UITapGestureRecognizer = {
        let recogizer = UITapGestureRecognizer()
        recogizer.addTarget(self, action: #selector(becomeFirstResponder))
        return recogizer
    }()
    
    func configure(with slotCount: Int = 6) {
        guard isConfigured == false else { return }
        isConfigured.toggle()
        
        configureTextField()
        
        let labelsStackView = createLabelsStackView(with: slotCount)
        addSubview(labelsStackView)
        addGestureRecognizer(tapRecognizer)
        
        NSLayoutConstraint.activate([
            labelsStackView.topAnchor.constraint(equalTo: topAnchor),
            labelsStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            labelsStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            labelsStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func configureTextField() {
        tintColor = .clear
        textColor = .clear
        keyboardType = .numberPad
        textContentType = .oneTimeCode
        
        addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        delegate = self
    }
    
    private func createLabelsStackView(with count: Int) -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        
        for index in 1 ... count {
            let label = UILabel()
            let container = UIView()
            let cursor = UIView()
            
            label.translatesAutoresizingMaskIntoConstraints = false
            container.translatesAutoresizingMaskIntoConstraints = false
            cursor.translatesAutoresizingMaskIntoConstraints = false
            
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 40, weight: .regular)
            label.isUserInteractionEnabled = true
            label.text = defaultCharacter
            label.backgroundColor = .lightGray
            label.layer.cornerRadius = 8
            label.layer.masksToBounds = true
            
            cursor.backgroundColor = .black
            cursor.alpha = index == 0 ? 1 : 0
            
            let animationBlock: (() -> Void)? = index == 0 ? {
                UIView.animate(withDuration: 1, delay: 0, options: [.repeat, .curveEaseIn], animations: {
                    cursor.alpha = 0
                }, completion: { _ in 
                    cursor.alpha = 1
                })
            } : nil
            
            if let animation = animationBlock {
                animation()
            }
            
            container.addSubview(label)
            container.addSubview(cursor)
            
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
                label.heightAnchor.constraint(equalTo: container.heightAnchor),
                label.widthAnchor.constraint(equalTo: container.widthAnchor)
            ])
            
            NSLayoutConstraint.activate([
                cursor.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                cursor.centerYAnchor.constraint(equalTo: container.centerYAnchor),
                cursor.heightAnchor.constraint(equalToConstant: self.frame.height/2.5),
                cursor.widthAnchor.constraint(equalToConstant: 2)
            ])
            
            stackView.addArrangedSubview(container)
            
            digitLabels.append(label)
            cursors.append(cursor)
        }
        
        return stackView
    }
    
    @objc private func textDidChange() {
        guard let text = self.text, text.count <= digitLabels.count else { return }
        
        for i in 0 ..< digitLabels.count {
            let currentLabel = digitLabels[i]
            let currentCursor = cursors[i]
            
            currentCursor.layer.removeAllAnimations()
            currentCursor.alpha = 0
            currentCursor.isHidden = true
            
            if i < text.count {
                let index = text.index(text.startIndex, offsetBy: i)
                currentLabel.text = String(text[index])
            } else {
                currentLabel.text = defaultCharacter
            }
        }
        
        if text.count < cursors.count {
            let currentCursor = cursors[text.count]
            currentCursor.alpha = 1
            currentCursor.isHidden = false
            animateCursor(cursor: currentCursor)
        }
        
        if text.count == digitLabels.count {
            didEnterLastDigit?(text)
        }
    }
    
    func animateCursor(cursor: UIView) {
        UIView.animate(withDuration: 1, delay: 0, options: [.repeat], animations: {
            cursor.alpha = 0
        }, completion: { _ in
            cursor.alpha = 1
        })
    }
}

extension OneTimeTextField: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let charactedCount = textField.text?.count else { return false }
        
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        
        if allowedCharacters.isSuperset(of: characterSet) {
            return charactedCount < digitLabels.count || string == ""
        } else {
            return false
        }
    }
}
