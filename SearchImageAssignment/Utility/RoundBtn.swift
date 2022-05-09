//
//  Extensions.swift
//  SearchImageAssignment
//
//  Created by shashant on 07/05/22.
//

import UIKit

@IBDesignable
class RoundBtn: UIButton {
    @IBInspectable public var cornerRadius: CGFloat = 0 {
            didSet {
                updateUI()
            }
        }
    
    
    private func updateUI() {
        
           layer.cornerRadius = cornerRadius
           if cornerRadius > 0 {
               layer.masksToBounds = true
           }
       }
}
