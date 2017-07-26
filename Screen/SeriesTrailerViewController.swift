//
//  SeriesTrailerViewController.swift
//  Screen
//
//  Created by Chandan Sarkar on 26.07.17.
//  Copyright © 2017 Chandan. All rights reserved.
//

import UIKit
import YouTubePlayer


class SeriesTrailerViewController: UIViewController {
    
    private var _seriesTrailerId: String?
    
    var seriesTrailerId: String {
        get {
            if _seriesTrailerId != nil {
                return _seriesTrailerId!
            }else {
                return ""
            }
        }
        set {
            _seriesTrailerId = newValue
        }
    }
    
    private var seriesTrailerPlayerView: YouTubePlayerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.createAndConfigureSeriesTrailer()
        if let topItem = self.navigationController?.navigationBar.topItem{
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        }
        self.setTranslucentNavigationBar()
        self.seriesTrailerPlayerView.play()
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
    
    func createAndConfigureSeriesTrailer() {
        let youtubePlayerFrame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: self.view.frame.height)
        self.seriesTrailerPlayerView = YouTubePlayerView(frame: youtubePlayerFrame)
        self.view.addSubview(seriesTrailerPlayerView)
        if seriesTrailerId != "" {
            self.seriesTrailerPlayerView.loadVideoID(seriesTrailerId)
        }
    }
}
