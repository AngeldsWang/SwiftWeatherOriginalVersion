//
//  ViewController.swift
//  SwiftWeather
//
//  Created by ZhenjunWang on 1/12/15.
//  Copyright (c) 2015 angeldswang. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var temperature: UILabel!
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingText: UILabel!
    
    let locationManager: CLLocationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let backgroud = UIImage(named: "background")
        self.view.backgroundColor = UIColor(patternImage: backgroud!)
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        if ios8() {
            locationManager.requestAlwaysAuthorization()
        }
        loadingIndicator.startAnimating()
        locationManager.startUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func ios8() -> Bool {
        return UIDevice.currentDevice().systemVersion.componentsSeparatedByString(".")[0] == "8"
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var location: CLLocation = locations[locations.count - 1] as CLLocation
        if location.horizontalAccuracy > 0 {
            println(location.coordinate.latitude)
            println(location.coordinate.longitude)
            self.updateWeatherInfo(location.coordinate.latitude, longitude: location.coordinate.longitude)
            locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println(error)
        self.loadingText.text = "Weather information is not available."
    }
    
    func updateWeatherInfo(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let manager = AFHTTPRequestOperationManager()
        
        let url = "http://api.openweathermap.org/data/2.5/weather"
        
        let params = ["lat": latitude, "lon": longitude]
        
        manager.GET(url, parameters: params,
            success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                println("JSON: " + responseObject.description!)
                self.updateUISuccess(responseObject as NSDictionary!)
            }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
            println("error: " + error.localizedDescription)
            })
        
    }
    
    func updateUISuccess(jsonObject: NSDictionary!) {
        
        self.loadingIndicator.hidden = true
        self.loadingIndicator.stopAnimating()
        self.loadingText.text = nil
        
        if let tempResult = jsonObject["main"]?["temp"]? as? Double {
            var temperature: Double
            if jsonObject["sys"]?["country"]? as String == "US" {
                temperature = round((( tempResult - 273.15 ) * 1.8) + 32)
            } else {
                temperature = round( tempResult - 273.15 )
            }
            
            self.temperature.text = "\(temperature)°"
            
            var cityName = jsonObject["name"]? as String
            self.location.text = cityName
            
            var conditionCode = (jsonObject["weather"]? as NSArray)[0]["id"]? as Int
            var sunrise = jsonObject["sys"]?["sunrise"]? as Double
            var sunset = jsonObject["sys"]?["sunset"]? as Double

            var isNight = false
            var now = NSDate().timeIntervalSince1970
            if now < sunrise || now > sunset {
                isNight = true
            }
            self.updateWeatherIcon(conditionCode, isNight: isNight)
            
        } else {
            self.loadingText.text = "Weather information is not available."
        }
    }
    
    func updateWeatherIcon(conditionCode: Int, isNight: Bool) {
        // thunderstorm
        if conditionCode < 300 {
            if isNight {
                self.weatherIcon.image = UIImage(named: "tstorm1_night")
            } else {
                self.weatherIcon.image = UIImage(named: "tstorm1")
            }
        } else if conditionCode < 500 {     // drizzle
            self.weatherIcon.image = UIImage(named: "light_rain")
        } else if conditionCode < 600 {     // rain
            self.weatherIcon.image = UIImage(named: "shower3")
        } else if conditionCode < 700 {     // snow
            self.weatherIcon.image = UIImage(named: "snow4")
        } else if conditionCode < 771 {     // fog/mist/haze/etc.
            if isNight {
                self.weatherIcon.image = UIImage(named: "fog_night")
            } else {
                self.weatherIcon.image = UIImage(named: "fog")
            }
        } else if conditionCode < 800 {     // squalls/tornado
            self.weatherIcon.image = UIImage(named: "tstorm3")
        } else if conditionCode == 800 {    // sunny
            if isNight {
                self.weatherIcon.image = UIImage(named: "sunny_night")
            } else {
                self.weatherIcon.image = UIImage(named: "sunny")
            }
        } else if conditionCode < 804 {     // clouds
            if isNight {
                self.weatherIcon.image = UIImage(named: "cloudy2_night")
            } else {
                self.weatherIcon.image = UIImage(named: "cloudy2")
            }
        } else if conditionCode == 804 {    // overcast
            self.weatherIcon.image = UIImage(named: "overcast")
        } else if ( conditionCode >= 900 && conditionCode < 903 ) || ( conditionCode > 904 && conditionCode <= 1000 ) {
            // extreme
            self.weatherIcon.image = UIImage(named: "tstorm3")
        } else if conditionCode == 903 {    // cold
            self.weatherIcon.image = UIImage(named: "snow5")
        } else if conditionCode == 904 {    // hot
            self.weatherIcon.image = UIImage(named: "sunny")
        } else {
            self.weatherIcon.image = UIImage(named: "dunno")
        }
    }

}

