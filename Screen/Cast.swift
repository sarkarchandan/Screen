//
//  Cast.swift
//  Screen
//
//  Created by Chandan Sarkar on 25.07.17.
//  Copyright © 2017 Chandan. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

class Cast: NSManagedObject {
    
    // Attempts to download and persist the Cast data for a Series
    class func downloadAndPersistCasts(_ seriesEntity: Series, _ context: NSManagedObjectContext) {
        if seriesEntity.toCast?.count == 0 {
            let SERIES_CREDIT_URL = "\(BASE_URL_TV)\(seriesEntity.id)\(TV_CREDIT_PARAM)\(AUTH_PARAM)\(API_KEY)"
            Alamofire.request(SERIES_CREDIT_URL).responseJSON { response in
                if let seriesCreditDictionary = response.result.value as? [String:Any]{
                    if let seriesCredits = seriesCreditDictionary["cast"] as? [[String:Any]] {
                        for credit in seriesCredits {
                            let cast = Cast(context: context)
                            if let name = credit["name"] as? String {
                                cast.actor_name = name
                            }
                            if let actorId = credit["id"] as? Int32 {
                                cast.actorId = actorId
                            }
                            if let alias = credit["character"] as? String {
                                cast.series_alias = alias
                            }
                            if let credit_id = credit["credit_id"] as? String {
                                cast.series_cast_Id = credit_id
                            }
                            if let profile_path = credit["profile_path"] as? String {
                                cast.profile_path = "\(BASE_URL_PROFILE)\(profile_path)"
                            }
                            seriesEntity.addToToCast(cast)
                            try? context.save()
                        }
                    }
                }
            }
        }
    }
}


