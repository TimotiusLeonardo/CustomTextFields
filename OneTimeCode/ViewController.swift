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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardWhenTappedAround()
        textField.configure()
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
            print(value)
        }
    }
    
    @IBAction func onToggleError(_ sender: Any) {
        materialTextField.updateStatusState(.error, message: "Error Toggle", borderWidth: 2)
        UIView.transition(with: mockView, duration: 0.1, options: .preferredFramesPerSecond60, animations: {
            self.mockViewTopAnchor.constant = 16
        }, completion: nil)
    }
    
    @IBAction func onToggleWarning(_ sender: Any) {
        materialTextField.updateStatusState(.warning, message: "Warning Toggle")
        UIView.transition(with: mockView, duration: 0.2, options: .showHideTransitionViews, animations: {
            self.mockViewTopAnchor.constant = 16
        }, completion: nil)
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

