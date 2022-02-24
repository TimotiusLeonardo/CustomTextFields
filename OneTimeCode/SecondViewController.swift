//
//  SecondViewController.swift
//  OneTimeCode
//
//  Created by Timotius Leonardo Lianoto on 24/02/22.
//

import UIKit

class SecondViewController: UIViewController, MaterialTextViewDelegate {
    func didChangeValue(_ textView: MaterialTextView) {
        
    }
    
    @IBOutlet weak var materialTextView: MaterialTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        view.backgroundColor = .white
        
        materialTextView.updateStatusState(.error, message: "Halo sayang", borderWidth: 2)
        materialTextView.mtv_textFieldDelegate = self
        materialTextView.topPadding = 50
    }
}
