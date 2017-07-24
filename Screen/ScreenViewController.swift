//
//  ScreenViewController.swift
//  Screen
//
//  Created by Chandan Sarkar on 23.07.17.
//  Copyright © 2017 Chandan. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

class ScreenViewController: UIViewController,
UITableViewDelegate,
UITableViewDataSource,
NSFetchedResultsControllerDelegate {
    
    
    @IBOutlet weak var seriesTableViewOutlet: UITableView!
    
    // Getting an optional reference of the NSPersistentContainer
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer

    // Declaring the reference of NSFetchedResultControllerDelegate
    var seriesFetchedResultController: NSFetchedResultsController<Series>!
    
    var displayObjectCount: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeNavigationBarTransparent()
        self.seriesTableViewOutlet.dataSource = self
        self.seriesTableViewOutlet.delegate = self
        self.downloadSeriesData {
            self.seriesTableViewOutlet.reloadData()
        }
        self.attemptFetchSeriesData()
    }
    
    // Makes the NavigationBar Transparent
    func makeNavigationBarTransparent() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
    }
    
    // Downloads Series with Alamofire
    func downloadSeriesData(completed: @escaping DownloadComplete) {
        let PAGE_VALUE = 1
        let BASIC_TV_DATA_URL = "\(BASE_URL_TV)\(TV_TYPE_POPULAR)\(AUTH_PARAM)\(API_KEY)\(PAGE_PARAM)\(String(describing: PAGE_VALUE))"
        Alamofire.request(BASIC_TV_DATA_URL).responseJSON { response in
            if let data = response.result.value as? [String:Any] {
                if let series_array = data["results"] as? [[String:Any]] {
                    self.persistBasicSeriesData(series_array)
                }
            }
            completed()
        }
    }
    
    // Attepts to persist Series data into Datastore
    func persistBasicSeriesData(_ seriesData: [[String:Any]]) {
        self.container?.performBackgroundTask { context in
            try? Series.persistSeriesDataWithCheck(data: seriesData, in: context)
            try? context.save()
        }
        printDatabaseStatistic()
    }
    
    // Checks whether the persistence is successful
    func printDatabaseStatistic(){
        container?.viewContext.perform {
            if Thread.isMainThread {
                print("Main Thread")
            }else{
                print("Background Thread")
            }
            if (self.container?.viewContext) != nil {
                let seriesFethcRequest: NSFetchRequest<Series> = Series.fetchRequest()
                if let seriesCount = (try? self.container?.viewContext.fetch(seriesFethcRequest))??.count {
                    print("Series Count: \(seriesCount)")
                }
            }
        }
    }
    
    // Attempts to fetch the Series data from Datastore
    func attemptFetchSeriesData() {
        let seriesFetchRequest: NSFetchRequest<Series> = Series.fetchRequest()
        let defaultSortDescriptor = NSSortDescriptor(key: "rating", ascending: false)
        seriesFetchRequest.sortDescriptors = [defaultSortDescriptor]
        seriesFetchedResultController = NSFetchedResultsController(fetchRequest: seriesFetchRequest, managedObjectContext: viewContext!, sectionNameKeyPath: nil, cacheName: nil)
        self.seriesFetchedResultController.delegate = self
        do {
            try self.seriesFetchedResultController.performFetch()
        }
        catch {
            let error = error as NSError
            print("Error Occurred during fetch: \(error)")
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.seriesTableViewOutlet.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.seriesTableViewOutlet.endUpdates()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let sections = seriesFetchedResultController.sections {
            return sections.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = seriesFetchedResultController.sections {
            let sectionInfo = sections[section]
            displayObjectCount = sectionInfo.numberOfObjects
            return sectionInfo.numberOfObjects
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "seriesCell") as? SeriesCell {
            let series = self.seriesFetchedResultController.object(at: indexPath)
            cell.configureCell(series)
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(200)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if displayObjectCount != nil {
            if (indexPath.row + 5) == displayObjectCount {
                print("End Is Near")
            }
        }
        // MARK: - Will try to use this to download next set of data
    }
}

