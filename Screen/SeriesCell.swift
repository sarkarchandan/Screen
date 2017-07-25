//
//  SeriesCell.swift
//  Screen
//
//  Created by Chandan Sarkar on 24.07.17.
//  Copyright © 2017 Chandan. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class SeriesCell: UITableViewCell {
    
    @IBOutlet weak var seriesBackDrop: RoundImageView!
    @IBOutlet weak var seriesName: UILabel!
    @IBOutlet weak var seriesRating: UILabel!
    @IBOutlet weak var seriesGenres: UILabel!
    @IBOutlet weak var numberOfSeasons: UILabel!
    
    // Configures the Series Cell
    func configureCell(_ series: Series) {
        Alamofire.request(series.poster_path!).responseImage { response in
            if let image = response.result.value{
                self.seriesBackDrop.image = image
            }
        }
        self.seriesName.text = series.name
        self.seriesRating.text = "TMDB \(series.rating) /10"
        
        let SERIES_DETAIL_URL = "\(BASE_URL_TV)\(series.id)\(AUTH_PARAM)\(API_KEY)"
        
        Alamofire.request(SERIES_DETAIL_URL).responseJSON { response in
            if let seriesDetail = response.result.value as? [String:Any] {
                
                if let seasons = seriesDetail["seasons"] as? [[String:Any]] {
                    self.numberOfSeasons.text = "\(seasons.count) Seasons"
                }
                
                if let seriesGenres = seriesDetail["genres"] as? [[String:Any]] {
                    for genre in seriesGenres {
                        self.seriesGenres.text = (genre["name"] as! String)
                    }
                }
            }
        }
        print("\(String(describing: series.id)): \(String(describing: series.toCast?.count))")
    }
}
