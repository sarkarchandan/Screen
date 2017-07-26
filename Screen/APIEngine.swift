//
//  APIEngine.swift
//  Screen
//
//  Created by Chandan Sarkar on 24.07.17.
//  Copyright © 2017 Chandan. All rights reserved.
//

import Foundation


let BASE_ENDPOINT = "http://api.themoviedb.org/3/"
let BASE_IMAGE_ENDPOINT = "http://image.tmdb.org/t/p/"
let BASE_URL_TV = "\(BASE_ENDPOINT)tv/"
let BASE_URL_PERSON = "\(BASE_ENDPOINT)person/"
let BASE_URL_POSTER = "\(BASE_IMAGE_ENDPOINT)w780"
let BASE_URL_BACKDROP = "\(BASE_IMAGE_ENDPOINT)w1280"
let BASE_URL_PROFILE = BASE_URL_BACKDROP
let BASE_URL_TV_GENRES = "\(BASE_ENDPOINT)genre/tv/list\(AUTH_PARAM)"

let AUTH_PARAM = "?api_key="
let TV_TYPE_POPULAR = "popular"
let TV_CREDIT_PARAM = "/credits"
let TV_VIDEO_PARAM = "/videos"
let PAGE_PARAM = "&page="
var PAGE_VALUE = 1

//Your API Key goes here//
let API_KEY = "API Key Here"

let NEW_DATA_AVAILABLE_ALERT_TITLE = "More Serieses"
let NEW_DATA_AVAILABLE_ALERT_MESSAGE = "Refresh the view to explore more serieses"

//Custom closure that will denote the completion of the download
typealias DownloadComplete = () -> ()
