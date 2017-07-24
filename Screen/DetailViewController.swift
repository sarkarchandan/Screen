//
//  DetailViewController.swift
//  Screen
//
//  Created by Chandan Sarkar on 24.07.17.
//  Copyright © 2017 Chandan. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class DetailViewController: UIViewController {
    
    private var _series: Series!
    
    var series: Series {
        get {
            return _series
        }
        set {
            _series = newValue
        }
    }
    
    @IBOutlet weak var backdropOutlet: GradientView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        if let topItem = self.navigationController?.navigationBar.topItem{
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        }
        setTranslucentNavigationBar()
        loadBackdropImage()
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
    
    func loadBackdropImage() {
        Alamofire.request(series.backdrop_path!).responseImage { response in
            if let image = response.result.value {
                self.backdropOutlet.image = image
            }
        }
    }
}


