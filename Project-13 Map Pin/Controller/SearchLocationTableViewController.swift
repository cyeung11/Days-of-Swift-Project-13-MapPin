//
//  SearchLocationTableViewController.swift
//  Project-13 Map Pin
//
//  Created by Chris on 6/10/2018.
//  Copyright © 2018 Chris. All rights reserved.
//

import UIKit
import MapKit

class SearchLocationTableViewController: UITableViewController, UISearchBarDelegate {

    var searchHelper: MKLocalSearch?
    var region: MKCoordinateRegion!
    var searchResult = [(name: String, placemark: CLPlacemark)]()
    
    @IBOutlet weak var searchBar: UISearchBar!{
        didSet{
            searchBar.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = true
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return searchResult.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let entity = searchResult[indexPath.item]
        cell.textLabel?.text = entity.name
        return cell
    }
    
    
    // MARK: - UISearchBarDelegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchHelper = searchHelper{
            searchHelper.cancel()
        }
        let mkSearchRequest = MKLocalSearchRequest()
        mkSearchRequest.naturalLanguageQuery = searchBar.text
        mkSearchRequest.region = region
        searchHelper = MKLocalSearch(request: mkSearchRequest)
        searchHelper?.start(completionHandler: { (response, _) in
            self.searchResult.removeAll()
            if let response = response{
                for item in response.mapItems{
                    if let name = item.name{
                        self.searchResult.append((name: name, placemark: item.placemark))
                    }
                }
            }
            self.tableView.reloadData()
        })
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let placemark = searchResult[indexPath.item].placemark
        if let location = placemark.location,
            let navVc = presentingViewController as? UINavigationController,
            let mapVC = navVc.viewControllers.last as? MapViewController{
            dismiss(animated: true, completion: {
                mapVC.mapView.setRegion(MKCoordinateRegionMakeWithDistance(location.coordinate, 1000.0, 1000.0), animated: true)
            })
        }
    }
}
