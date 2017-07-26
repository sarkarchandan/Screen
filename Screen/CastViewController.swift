//
//  CastViewController.swift
//  Screen
//
//  Created by Chandan Sarkar on 26.07.17.
//  Copyright © 2017 Chandan. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class CastViewController: UIViewController {
    
    private var _cast: Cast!
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var profileImage: RoundImageView!
    @IBOutlet weak var actorNameOutlet: UILabel!
    @IBOutlet weak var aliasOutlet: UILabel!
    @IBOutlet weak var birthDateOutlet: UILabel!
    @IBOutlet weak var actorLocation: UILabel!
    @IBOutlet weak var actorBio: UILabel!
    
    var cast: Cast {
        get {
            return _cast
        }
        set {
            _cast = newValue
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let topItem = self.navigationController?.navigationBar.topItem{
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        }
        self.setTranslucentNavigationBar()
        self.configureCastImages()
        self.configureCastTextData()
        print("Actor Id: \(cast.actorId)")
    }
    
    // Configures the Translucent Navigation Bar
    func setTranslucentNavigationBar() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.view.backgroundColor = .clear
        self.navigationController?.navigationBar.barStyle = .blackOpaque
    }
    
    func configureCastImages() {
        if let profile_image_url = cast.profile_path {
            Alamofire.request(profile_image_url).responseImage { response in
                if let image = response.result.value {
                    self.backgroundImage.image = image
                    self.profileImage.image = image
                }
            }
        } else{
            self.backgroundImage.image = UIImage(named: "prof2.png")
            self.profileImage.image = UIImage(named: "prof2.png")
        }
    }
    
    func configureCastTextData(){
        let PERSON_URL = "\(BASE_URL_PERSON)\(cast.actorId)\(AUTH_PARAM)\(API_KEY)"
        Alamofire.request(PERSON_URL).responseJSON { response in
            if let castDetail = response.result.value as? [String:Any] {
                if let actorName = castDetail["name"] as? String {
                    self.actorNameOutlet.text = actorName
                }
                if let alias = self.cast.series_alias {
                    self.aliasOutlet.text = "as \(alias)"
                }
                if let birthDate = castDetail["birthday"] as? String {
                    self.birthDateOutlet.text = "Born on  \(birthDate)"
                }
                if let location = castDetail["place_of_birth"] as? String {
                    self.actorLocation.text = location
                }
                if let actorBio = castDetail["biography"] as? String {
                    if actorBio != "" {
                        self.actorBio.text = actorBio
                    } else {
                        self.actorBio.text = "No Information Available"
                    }
                }
            }
        }
    }
}
