//
//  CastCollectionViewCell.swift
//  Screen
//
//  Created by Chandan Sarkar on 25.07.17.
//  Copyright © 2017 Chandan. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class CastCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var castImageOutlet: RoundImageView!
    @IBOutlet weak var castNameOutlet: UILabel!
    
    func configureCastCell(_ cast: Cast) {
        self.castNameOutlet.text = cast.actor_name
        if let profile_url = cast.profile_path {
            Alamofire.request(profile_url).responseImage { response in
                if let actorImage = response.result.value {
                    self.castImageOutlet.image = actorImage
                }
            }
        }
    }
}
