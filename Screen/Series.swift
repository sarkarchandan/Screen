//
//  Series.swift
//  Screen
//
//  Created by Chandan Sarkar on 23.07.17.
//  Copyright © 2017 Chandan. All rights reserved.
//

import UIKit
import CoreData

class Series: NSManagedObject {
    
    //Persists the basic series data with checking prior existence
    class func persistSeriesDataWithCheck(data serieses: [[String:Any]] , in context: NSManagedObjectContext) throws {
        for series in serieses {
            if let seriesName = series["name"] as? String {
                let seriesFetchRequest: NSFetchRequest<Series> = Series.fetchRequest()
                let seriesPredicate = NSPredicate(format: "name == %@", seriesName)
                seriesFetchRequest.predicate = seriesPredicate
                
                do{
                    let matchingSerieses = try context.fetch(seriesFetchRequest)
                    assert(matchingSerieses.count <= 1, "Datastore inconsistency detected")
                    
                    if matchingSerieses.count == 0 {
                        let seriesEntity = Series(context: context)
                        if let seriesId = series["id"] as? Int32 {
                            seriesEntity.id = seriesId
                        }
                        seriesEntity.name = seriesName
                        seriesEntity.has_liked = false
                        if let seriesSynopsis = series["overview"] as? String {
                            seriesEntity.synopsis = seriesSynopsis
                        }
                        if let seriesRating = series["vote_average"] as? Double {
                            seriesEntity.rating = seriesRating
                        }
                        if let seriesPosterUri = series["poster_path"] as? String {
                            seriesEntity.poster_path = "\(BASE_URL_POSTER)\(seriesPosterUri)"
                        }
                        if let seriesBackdropUri = series["backdrop_path"] as? String {
                            seriesEntity.backdrop_path = "\(BASE_URL_BACKDROP)\(seriesBackdropUri)"
                        }
                        if let seriesFirstAirDate = series["first_air_date"] as? NSDate {
                            seriesEntity.first_air_date = seriesFirstAirDate
                        }
                        if let seriesGenreIds = series["genre_ids"] as? [Int] {
                            seriesEntity.toGenre?.addingObjects(from: seriesGenreIds)
                        }
                    }
                }catch{
                    throw error
                }
            }
        }
    }
}
