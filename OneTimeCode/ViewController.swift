//
//  ViewController.swift
//  OneTimeCode
//
//  Created by Timotius Leonardo Lianoto on 08/12/21.
//

import UIKit

class ViewController: UIViewController, MaterialPlaceholderDelegate {
    @IBOutlet var textField: OneTimeTextField!
    @IBOutlet weak var materialTextField: MaterialPlaceHolderTextField!
    @IBOutlet var label: UILabel!
    @IBOutlet var mockView: UIView!
    @IBOutlet weak var mockViewTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var viewInStackView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardWhenTappedAround()
        textField.configure(backgroundColor: .red, textColor: .white, cursorColor: .white, font: .systemFont(ofSize: 20, weight: .bold))
        textField.didEnterLastDigit = { [weak self] code in
            let alert = UIAlertController(title: "Success", message: code, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay!", style: .default, handler: { _ in
                alert.dismiss(animated: true, completion: nil)
            }))
            self?.present(alert, animated: true, completion: nil)
        }
        
        materialTextField.placeholderText = "Enter Your Password"
        materialTextField.placeholderTextColor = .black
        materialTextField._cornerRadius = 8
        materialTextField._borderWidth = 0
        materialTextField.mtf_textFieldDelegate = self
        materialTextField.isSecureTextEntry = true
    }
    
    @objc func startTextField() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                if self.view.frame.origin.y == 0 {
                    self.view.frame.origin.y -= keyboardSize.height
                }
            }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y = 0
            }
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func didChangeValue(value: String?) {
        if let value = value {
            if !value.trimmingCharacters(in: .whitespacesAndNewlines).isPhoneNumber() {
                materialTextField.updateStatusState(.error, message: "Bukan Nomor HP", borderWidth: 2)
                UIView.transition(with: mockView, duration: 0.1, options: .preferredFramesPerSecond60, animations: {
                    self.mockViewTopAnchor.constant = 24
                }, completion: nil)
            } else {
                materialTextField.updateStatusState(.normal, message: nil, borderWidth: 0)
            }
        }
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let trimmedText = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let emailRegEx = "(?:[a-z0-9]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"+"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"+"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"+"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"+"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"+"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"+"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
            
            let emailTest = NSPredicate(format:"SELF MATCHES[c] %@", emailRegEx)
            return emailTest.evaluate(with: trimmedText)
    }
    
    @IBAction func onToggleError(_ sender: Any) {
        materialTextField.updateStatusState(.error, message: "Error Toggle", borderWidth: 2)
        self.mockViewTopAnchor.constant = 24
        self.viewInStackView.isHidden = true
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func onToggleWarning(_ sender: Any) {
        materialTextField.updateStatusState(.warning, message: "Warning Toggle")
        self.viewInStackView.isHidden = false
        self.mockViewTopAnchor.constant = 24
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func onToggleNormal(_ sender: Any) {
        materialTextField.updateStatusState(.normal, message: "Normal Toggle")
        mockViewTopAnchor.constant = 8
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tapGesture = UITapGestureRecognizer(target: self,
                         action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
}


extension String {
    func isEmail() -> Bool {
        return __emailPredicate.evaluate(with: self)
    }
    
    func isPhoneNumber() -> Bool {
        return __phonePredicate.evaluate(with: self)
    }
}
