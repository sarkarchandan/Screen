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
    @IBOutlet weak var nameOutlet: UILabel!
    @IBOutlet weak var firstAirDateOutlet: UILabel!
    @IBOutlet weak var ratingOutlet: RoundLabel!
    @IBOutlet weak var synopsisOutlet: UILabel!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        if let topItem = self.navigationController?.navigationBar.topItem{
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        }
        setTranslucentNavigationBar()
        updateSeriesInformation()
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
    
    func updateSeriesInformation() {
        self.nameOutlet.text = series.name
        self.firstAirDateOutlet.text = series.first_air_date
        self.ratingOutlet.text = "\(series.rating)/10"
        self.synopsisOutlet.text = series.synopsis
    }
}


