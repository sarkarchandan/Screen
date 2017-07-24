//
//  GradientImageView.swift
//  Screen
//
//  Created by Chandan Sarkar on 24.07.17.
//  Copyright © 2017 Chandan. All rights reserved.
//

import UIKit

class GradientView: UIImageView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let gradient = CAGradientLayer()
        
        gradient.frame = self.bounds
        let startColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 1)
        let endColor = UIColor.black.cgColor
        gradient.colors = [startColor,endColor]
        self.layer.insertSublayer(gradient, at: 0)
    }
}

