//
//  Constants.swift
//  OneTimeCode
//
//  Created by Timotius Leonardo Lianoto on 20/12/21.
//

import Foundation

let __firstpart = "(?:[a-z0-9_-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"+"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"+"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")"
let __serverpart = "([A-Z0-9a-z]([A-Z0-9a-z-]{0,30}[A-Z0-9a-z])?\\.){1,5}"
let __emailRegex = __firstpart + "@" + __serverpart + "[A-Za-z]{2,8}"
let __emailPredicate = NSPredicate(format: "SELF MATCHES %@", __emailRegex)
let __phoneRegex = "^[0-9+]+[0-9]$"
let __phonePredicate = NSPredicate(format: "SELF MATCHES %@", __phoneRegex)
