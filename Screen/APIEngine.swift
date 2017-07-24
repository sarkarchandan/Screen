//
//  APIEngine.swift
//  Screen
//
//  Created by Chandan Sarkar on 23.07.17.
//  Copyright © 2017 Chandan. All rights reserved.
//

import Foundation


import Foundation

let BASE_URL_TV = "http://api.themoviedb.org/3/tv/"
let AUTH_PARAM = "?api_key="
let TV_TYPE_POPULAR = "popular"
let PAGE_PARAM = "&page="

let BASE_URL_POSTER = "http://image.tmdb.org/t/p/w780"
let BASE_URL_BACKDROP = "http://image.tmdb.org/t/p/w1280"

let BASE_URL_TV_GENRES = "https://api.themoviedb.org/3/genre/tv/list?api_key="

//Your API Key goes here//
let API_KEY = "47bf13c16d3abc75b010e49a6cd2467a"

//Custom closure that will denote the completion of the download
typealias DownloadComplete = () -> ()
