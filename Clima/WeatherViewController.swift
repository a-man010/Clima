//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "c7c17d8e328df5df4299fffae1a47d73"
    

    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    
    func getWeatherData(url : String, parameter : [String:String]){
    
        Alamofire.request(url, method: .get, parameters : parameter).responseJSON{
            response in
            if response.result.isSuccess{
                print("Success! Got the Weather data")
                let weatherJSON : JSON = JSON(response.result.value!)
                
                self.updateWeatherData(json : weatherJSON)
                
            }
            else{
                print("Error: \(response.result.error!)")
                self.cityLabel.text="Connection failed!"
            }
        }
    }

    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    func updateWeatherData(json:JSON){
        
        if let tempResult = json["main"]["temp"].double{
            
        weatherDataModel.temprature = Int(tempResult - 273.15)
        weatherDataModel.city = json["name"].stringValue
        weatherDataModel.condition = json["weather"][0]["id"].intValue
        weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            
         updateUIWithWeatherUpdate()
        }
        
        else{
            cityLabel.text = "Unable to fetch data"
        }
    }
    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    func updateUIWithWeatherUpdate ( ){
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = String(weatherDataModel.temprature)
        weatherIcon.image = UIImage (named : weatherDataModel.weatherIconName)
    }
    
     
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            let params : [String:String] = ["lat" : latitude , "lon" : longitude , "appid" : APP_ID]
            
            print("Longitude : \(longitude)  Latitude : \(latitude)")
            
            getWeatherData(url : WEATHER_URL, parameter : params)
            
            
        }
    }
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        cityLabel.text = "Location unavailable"
        
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    func userEnteredANewCityName(city: String) {
        let params : [String:String] = ["q" : city, "appid" : APP_ID]
        getWeatherData(url: WEATHER_URL, parameter: params)
        print(city)
        
    }

    
    //Write the PrepareForSegue Method here
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName"{
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.ccdDelegate = self
        }
    }
    
    
    
    
}


