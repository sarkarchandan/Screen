//
//  MaterialView.swift
//  Screen
//
//  Created by Chandan Sarkar on 23.07.17.
//  Copyright © 2017 Chandan. All rights reserved.
//

import UIKit

private var _usingMaterialDesign = false

extension UIView {
    @IBInspectable var usingMaterialDesign: Bool {
        get {
            return _usingMaterialDesign
        }
        
        set {
            _usingMaterialDesign = newValue
            if _usingMaterialDesign {
                self.layer.masksToBounds = false
                self.layer.cornerRadius = 4.0
                self.layer.shadowRadius = 4.0
                self.layer.shadowOpacity = 0.8
                self.layer.shadowOffset = CGSize(width: 0.0, height: 4.0)
                self.layer.shadowColor = UIColor(displayP3Red: 157/255, green: 157/255, blue: 157/255, alpha: 1.0).cgColor
            }else {
                self.layer.cornerRadius = 0
                self.layer.shadowOpacity = 0
                self.layer.shadowRadius = 0
                self.layer.shadowColor = nil
            }
        }
    }
}
