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
    @IBOutlet weak var IdnMaterialTextView: IDNMaterialTextView!
    
    lazy var button = UIButton(frame: .init(x: 0, y: 0, width: 100, height: 100))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        view.backgroundColor = .white
        
        materialTextView.updateStatusState(.error, borderWidth: 2)
        materialTextView.mtv_textFieldDelegate = self
        materialTextView.topPadding = 50
        
        button.setTitle("Show Hint", for: .normal)
        button.setTitleColor(.brown, for: .normal)
        view.addSubview(button)
        button.center = view.center
        button.addTarget(self, action: #selector(showHint), for: .touchUpInside)
        
        IdnMaterialTextView.hintLabelPadding = .init(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    @objc func showHint() {
        IdnMaterialTextView.materialTextView.updateStatusState(.error, borderWidth: 2)
        IdnMaterialTextView.hintMessage = "Makan yuk"
    }
}
