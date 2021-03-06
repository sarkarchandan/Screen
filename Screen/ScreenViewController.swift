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
NSFetchedResultsControllerDelegate,
UISearchBarDelegate {
    
    
    @IBOutlet weak var seriesTableViewOutlet: UITableView!
    @IBOutlet weak var segmentPickerOutlet: UISegmentedControl!
    
    // Getting an optional reference of the NSPersistentContainer
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer

    // Declaring the reference of NSFetchedResultControllerDelegate
    var seriesFetchedResultController: NSFetchedResultsController<Series>!
    
    // Declaring the reference of NSFetchedRequest
    var seriesFetchRequest: NSFetchRequest<Series>!
    
    //UISearchController reference as Optional
    private var searchController: UISearchController?
    
    var displayObjectCount: Int?
    
    // Flag to determine if the user is seraching
    var searchMode: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeNavigationBarTransparent()
        self.seriesTableViewOutlet.dataSource = self
        self.seriesTableViewOutlet.delegate = self
        self.downloadSeriesData {
            self.seriesTableViewOutlet.reloadData()
        }
        self.attemptFetchSeriesData()
        searchController?.searchBar.delegate = self
        searchController?.searchBar.returnKeyType = UIReturnKeyType.done
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
    
    // IBAction function for the Search Functionality
    @IBAction func searchBarButtonClicked(_ sender: UIBarButtonItem) {
        searchController = UISearchController(searchResultsController: nil)
        searchController?.hidesNavigationBarDuringPresentation = true
        searchController?.searchBar.keyboardType = UIKeyboardType.default
        searchController?.searchBar.placeholder = "Looking for a series !!!"
        searchController?.searchBar.searchBarStyle = UISearchBarStyle.minimal
        (searchController?.searchBar.value(forKey: "searchField") as? UITextField)?.textColor = UIColor.black
        searchController?.searchBar.tintColor = UIColor.black
        self.searchController?.searchBar.delegate = self
        self.segmentPickerOutlet.isHidden = true
        present(searchController!, animated: true, completion: nil)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.segmentPickerOutlet.isHidden = false
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.segmentPickerOutlet.isHidden = false
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
        seriesFetchRequest = Series.fetchRequest()
        
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
            if (indexPath.row + 5) == displayObjectCount {
                self.downloadSeriesData {
                    self.attemptFetchSeriesData()
                    self.createAlert()
                }
                self.seriesTableViewOutlet.reloadData()
            }
        }
    }
    
    func createAlert() {
        let newSeriesDataAlert = UIAlertController(title: NEW_DATA_AVAILABLE_ALERT_TITLE, message: NEW_DATA_AVAILABLE_ALERT_MESSAGE, preferredStyle: UIAlertControllerStyle.alert)
        newSeriesDataAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: { (action) in
            newSeriesDataAlert.dismiss(animated: true, completion: nil)
        }))
        self.present(newSeriesDataAlert, animated: true, completion: nil)
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
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchController?.searchBar.text == nil || searchController?.searchBar.text == "" {
            searchMode = false
            self.seriesTableViewOutlet.reloadData()
            self.view.endEditing(true)
        } else{
            searchMode = true
            print("Typed Char: \(searchText)")
            let searchPredicate = NSPredicate(format: "( name BEGINSWITH[c] %@ ) || ( name CONTAINS[c] %@ )",searchText)
            self.seriesFetchRequest.predicate = searchPredicate
            self.attemptFetchSeriesData()
            self.seriesTableViewOutlet.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.attemptFetchSeriesData()
        self.seriesTableViewOutlet.reloadData()
        self.view.endEditing(true)
    }
}

