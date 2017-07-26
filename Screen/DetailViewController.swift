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
import CoreData

class DetailViewController:
UIViewController,
UICollectionViewDataSource,
UICollectionViewDelegate {
    
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
    @IBOutlet weak var castCollectionViewOutlet: UICollectionView!
    @IBOutlet weak var likeBarButtonOutlet: UIBarButtonItem!
    @IBOutlet weak var trailerButtonOutlet: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let topItem = self.navigationController?.navigationBar.topItem{
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        }
        self.setTranslucentNavigationBar()
        self.updateSeriesInformation()
        self.loadBackdropImage()
        if series.has_liked == true {
            self.likeBarButtonOutlet.image = UIImage(named: "icons8-Heart Filled-30.png")
        }else {
            self.likeBarButtonOutlet.image = UIImage(named: "icons8-Heart_30.png")
        }
        self.castCollectionViewOutlet.dataSource = self
        self.castCollectionViewOutlet.delegate = self
        self.configureTrailerButton()
        print("Series Id: \(series.id)")
    }
    
    func configureTrailerButton() {
        let buttonImage = UIImage(named: "icons8_Circled_Play_70.png")?.withRenderingMode(.alwaysTemplate)
        self.trailerButtonOutlet.setImage(buttonImage, for: .normal)
        self.trailerButtonOutlet.tintColor = UIColor.white
    }
    
    @IBAction func trailerButtonPressed(_ sender: Any) {
        let BASE_VIDEO_URL = "\(BASE_URL_TV)\(series.id)\(TV_VIDEO_PARAM)\(AUTH_PARAM)\(API_KEY)"
        Alamofire.request(BASE_VIDEO_URL).responseJSON { response in
            if let videoArrayDictionary = response.result.value as? [String:Any] {
                if let videoArray = videoArrayDictionary["results"] as? [[String:Any]] {
                    for video in videoArray {
                        if let videoType = video["type"] as? String , videoType == "Trailer" || videoType == "Opening Credits" {
                            if let trailerId = video["key"] as? String {
                                self.performSegue(withIdentifier: "playTrailer", sender: trailerId)
                                break
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    @IBAction func likeButtonClicked(_ sender: Any) {
        if series.has_liked == false {
            series.has_liked = true
            self.likeBarButtonOutlet.image = UIImage(named: "icons8-Heart Filled-30.png")
        }else {
            series.has_liked = false
            self.likeBarButtonOutlet.image = UIImage(named: "icons8-Heart_30.png")
        }
        try? viewContext?.save()
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
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let seriesCastArray = series.toCast?.allObjects as? [Cast] {
            return seriesCastArray.count
        }else{
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "actorCell", for: indexPath) as? CastCollectionViewCell{
            if let seriesCastArray = series.toCast?.allObjects as? [Cast] {
                let cast = seriesCastArray[indexPath.row]
                cell.configureCastCell(cast)
            }
            return cell
        }else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let seriesCastArray = series.toCast?.allObjects as? [Cast] , seriesCastArray.count > 0  {
            let cast = seriesCastArray[indexPath.row]
            performSegue(withIdentifier: "castDetail", sender: cast)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? CastViewController {
            if let cast = sender as? Cast{
                destination.cast = cast
            }
        }
        if let destination = segue.destination as? SeriesTrailerViewController {
            if let trailerId = sender as? String {
                destination.seriesTrailerId = trailerId
            }
        }
    }
}


