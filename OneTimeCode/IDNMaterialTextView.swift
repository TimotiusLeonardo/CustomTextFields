//
//  IDNMaterialTextView.swift
//  OneTimeCode
//
//  Created by Timotius Leonardo Lianoto on 24/02/22.
//

import UIKit

class IDNMaterialTextView {
    private (set) lazy var hintLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.translatesAutoresizingMaskIntoConstraints = false
//        hintLabel.font = hintFont
//        hintLabel.numberOfLines = hintNumberOfLines
        return label
    }()
}
