//
//  SearchLocationVC.swift
//  Weather
//
//  Created by Burak on 24.10.2021.
//

import UIKit
import MapKit

class SearchLocationVC: UIViewController, UISearchBarDelegate, MKLocalSearchCompleterDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var searchResultsTable: UITableView!
    
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    
    var lat : Double?
    var lon : Double?
    var cityName : String?
    
    //MARK: - Hide Status Bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar?.delegate = self
        searchCompleter.delegate = self
        searchResultsTable?.delegate = self
        searchResultsTable?.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if Reachability.isConnectedToNetwork() == false {
            showNetworkAlert()
        }
    }
    
    @IBAction func goBackPressed(_ sender: UIButton) {
        dismissView()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    @objc func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    @objc(tableView:cellForRowAtIndexPath:) func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let searchResult = searchResults[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = searchResult.title
        cell.detailTextLabel?.text = searchResult.subtitle
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let result = searchResults[indexPath.row]
        let searchRequest = MKLocalSearch.Request(completion: result)
        
        let search = MKLocalSearch(request: searchRequest)
        search.start { (response, error) in guard let coordinate = response?.mapItems[0].placemark.coordinate else { return }
            guard let name = response?.mapItems[0].name else { return }
            
            self.lat = coordinate.latitude
            self.lon = coordinate.longitude
            self.cityName = name
            self.showAlert(title: "Location Added", description: "\(name) succesfully added to favorites!")
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchCompleter.queryFragment = searchText
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        searchResultsTable.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print(error)
    }
    
    func dismissView() {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    func showAlert(title : String, description : String) {
        let alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            self.dismissView()
            self.performSegue(withIdentifier: "goBackToPlaces", sender: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showNetworkAlert() {
        let alert = UIAlertController(title: "Caution", message: "You must have internet connection to use Weather app.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goBackToPlaces" {
            let destinationVC = segue.destination as! PlacesVC
            destinationVC.nameData = cityName
            destinationVC.latData = lat
            destinationVC.lonData = lon
        }
    }
}
