//
//  ViewController.swift
//  lopol
//
//  Created by Cesar Ibarra on 11/5/16.
//  Copyright © 2016 Cesar Ibarra. All rights reserved.
//

import UIKit
import Alamofire
import MapKit

class HomeViewController: UIViewController, UITableViewDataSource, UITextFieldDelegate, UITableViewDelegate {
    
    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var infoTableView: UITableView!
    private var reps = [String]()
    
    
    //TODO: Change reps to hold the entire data structue that I get back, or set up new network requests to pass data over to the detail view controller
    
    //MARK: - Random Stuff
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        switch identifier {
        case "showDetail":
            if let nextVC = segue.destination as? DetialViewController {
                guard let cell = sender as? UITableViewCell else {return}
                guard let path = infoTableView.indexPath(for: cell) else {return}
                nextVC.repDetail.append(reps[path.row])
            }
        default:
            break
        }
    }
    
    
    //MARK: - TableView Delegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showDetail", sender: tableView.cellForRow(at: indexPath))
    }
    
    //MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        infoTableView.dataSource = self
        address.delegate = self
    }
    
    //MARK: - Home Page UI
    @IBAction func launchMapAndTable(_ sender: UIButton) {
        if let address = address.text {
            getRepresentativesPopulateTable(address: address)
            setMapLocation(address: address)
        }
    }
    
    private func getRepresentativesPopulateTable(address: String) {
        let parameters = ["address": address, "key":Constants.APIKey]
        let url = Constants.baseURL + Constants.getRepresentatives + escapedParameters(parameters: parameters as [String : AnyObject])
        Alamofire.request(url).responseJSON { (response) in
            if let JSON = response.result.value {
                if let JSONDict = JSON as? NSDictionary {
                    guard let representatives = JSONDict["officials"] as? NSArray else {return}
                    for dict in representatives {
                        guard let dictionary = dict as? NSDictionary else {return}
                        guard let name = dictionary.value(forKey: "name") as? String else {return}
                        self.reps.append(name)
                    }
                }
                self.infoTableView.reloadData()
            }
        }
    }
    
    private func setMapLocation(address: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address, completionHandler: { (placemarks: Array<CLPlacemark>?, error: Error?) in
            if let marks = placemarks {
                if marks.count > 0 {
                    if let topResult = marks.first {
                        let placemark = MKPlacemark.init(placemark: topResult)
                        var region = self.map.region
                        guard let circularRegion = placemark.region as? CLCircularRegion else {return}
                        region.center = circularRegion.center
                        region.span.longitudeDelta /= 50.0
                        region.span.latitudeDelta /= 50.0
                        
                        self.map.setRegion(region, animated: true)
                        self.map.addAnnotation(placemark)
                    }
                }
            }
        })
    }
    
    //MARK: - InfoTableView Data Source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reps.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        cell?.textLabel?.text = reps[indexPath.row]
        return cell!
    }
    
    //MARK: - Networking Helpers
    private func escapedParameters(parameters: [String:AnyObject]) -> String {
        if parameters.isEmpty {
            return ""
        }
        var keyValuePairs = [String]()
        for (key, value) in parameters {
            let stringValue = "\(value)"
            if let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) {
                keyValuePairs.append(key + "=" + "\(escapedValue)")
            }
        }
        return "?\(keyValuePairs.joined(separator: "&"))"
    }
}

