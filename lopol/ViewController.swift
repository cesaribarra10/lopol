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

class ViewController: UIViewController {
    
    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var map: MKMapView!
    
    //MARK: - Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - Home Page UI
    @IBAction func launchMap(_ sender: UIButton) {
        if let address = address.text {
            getRepresentativesFromAPI(address: address)
            setMapLocation(address: address)
        }
    }
    
    private func getRepresentativesFromAPI(address: String) {
        let parameters = ["address": address, "key":Constants.APIKey]
        let url = Constants.baseURL + Constants.getRepresentatives + escapedParameters(parameters: parameters as [String : AnyObject])
        Alamofire.request(url).responseJSON { (response) in
            if let JSON = response.result.value {
                print(JSON)
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
                        let circularRegion = placemark.region as! CLCircularRegion
                        region.center = circularRegion.center
                        region.span.longitudeDelta /= 8.0
                        region.span.latitudeDelta /= 8.0
                        
                        self.map.setRegion(region, animated: true)
                        self.map.addAnnotation(placemark)
                    }
                }
            }
        })
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

//    private func apiCheck() {
//        let route = "https://www.googleapis.com/civicinfo/v2/representatives?address=2701+W+McFadden+Ave+Santa+Ana&key=AIzaSyDVjVpwWAq9I3qOUAChddsvnc_W7iMVjO0"
//        Alamofire.request(route).responseJSON { (response) in
//            if let JSON = response.result.value {
//                print(JSON)
//            }
//        }
//    }
}

