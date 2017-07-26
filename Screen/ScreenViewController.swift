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
    @IBOutlet weak var segmentPickerOutlet: UISegmentedControl!
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        self.segmentPickerOutlet.selectedSegmentIndex = 0
        self.attemptFetchSeriesData()
        self.seriesTableViewOutlet.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.seriesTableViewOutlet.reloadData()
    }
    
    
    @IBAction func refreshButtonClicked(_ sender: Any) {
        self.attemptFetchSeriesData()
        self.seriesTableViewOutlet.reloadData()
    }
    
    
    @IBAction func segmentChanged(_ sender: Any) {
        self.attemptFetchSeriesData()
        self.seriesTableViewOutlet.reloadData()
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
        var page_index: Int
        if let page = UserDefaults.standard.object(forKey: "series_page") as? Int {
            page_index = page
        }else{
            page_index = PAGE_VALUE
        }
        let BASIC_TV_DATA_URL = "\(BASE_URL_TV)\(TV_TYPE_POPULAR)\(AUTH_PARAM)\(API_KEY)\(PAGE_PARAM)\(String(describing: page_index))"
        print("Current Series URL: \(BASIC_TV_DATA_URL)")
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
        self.seriesTableViewOutlet.reloadData()
        printDatabaseStatistic()
        PAGE_VALUE += 1
        UserDefaults.standard.set(PAGE_VALUE, forKey: "series_page")
    }
    
    func persistCastData() {
        
    }
    
    // Checks whether the persistence is successful
    func printDatabaseStatistic(){
        container?.viewContext.perform {
            if viewContext != nil {
                let seriesFethcRequest: NSFetchRequest<Series> = Series.fetchRequest()
                if let seriesCount = (try? viewContext?.fetch(seriesFethcRequest))??.count {
                    print("Series Count: \(seriesCount)")
                }
            }
        }
    }
    
    // Attempts to fetch the Series data from Datastore
    func attemptFetchSeriesData() {
        let seriesFetchRequest: NSFetchRequest<Series> = Series.fetchRequest()
        
        var defaultSortDescriptor: NSSortDescriptor
        
        if self.segmentPickerOutlet.selectedSegmentIndex == 0 {
            defaultSortDescriptor = NSSortDescriptor(key: "rating", ascending: false)
            
        }else if self.segmentPickerOutlet.selectedSegmentIndex == 1 {
            defaultSortDescriptor = NSSortDescriptor(key: "first_air_date", ascending: false)
        }else if self.segmentPickerOutlet.selectedSegmentIndex == 2 {
            defaultSortDescriptor = NSSortDescriptor(key: "rating", ascending: false)
            let predicateForLikeSeries = NSPredicate(format: "has_liked == %@", true as CVarArg)
            seriesFetchRequest.predicate = predicateForLikeSeries
        }else {
            defaultSortDescriptor = NSSortDescriptor(key: "rating", ascending: false)
        }
        
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
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                self.seriesTableViewOutlet.insertRows(at: [indexPath], with: .fade)
            }
            break
        case .update:
            if let indexPath = indexPath {
                if let cell = self.seriesTableViewOutlet.cellForRow(at: indexPath) as? SeriesCell{
                    self.configureCell(cell, indexPath as NSIndexPath)
                }
            }
            break
        case .move:
            if let indexPath = indexPath {
                self.seriesTableViewOutlet.deleteRows(at: [indexPath], with: .fade)
            }
            if let indexPath = newIndexPath {
                self.seriesTableViewOutlet.insertRows(at: [indexPath], with: .fade)
            }
            break
        case .delete:
            if let indexPath = indexPath {
                self.seriesTableViewOutlet.deleteRows(at: [indexPath], with: .fade)
            }
            break
        }
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
            self.configureCell(cell, indexPath as NSIndexPath)
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func configureCell(_ cell: SeriesCell, _ indexPath: NSIndexPath) {
        let series = self.seriesFetchedResultController.object(at: indexPath as IndexPath)
        cell.configureCell(series)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(200)
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if displayObjectCount != nil {
            if (indexPath.row + 9) == displayObjectCount {
                print("End Is Near")
                self.downloadSeriesData {
                    self.attemptFetchSeriesData()
                }
                self.seriesTableViewOutlet.reloadData()
            }
        }
        // MARK: - Will try to use this to download next set of data
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let objects = seriesFetchedResultController.fetchedObjects , objects.count > 0 {
            let series = objects[indexPath.row]
            performSegue(withIdentifier: "seriesDetail", sender: series)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? DetailViewController {
            if let series = sender as? Series {
                destination.series = series
            }
        }
    }
}

