//
//  ViewController.swift
//  Weather
//
//  Created by Burak on 21.10.2021.
//

import UIKit
import Lottie
import CoreLocation
import SystemConfiguration

class MainVC: UIViewController, CLLocationManagerDelegate {
    
    //MARK: - Location Data
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    
    //MARK: - Date Data
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet var timeOfDayLabel: UILabel!
    
    //MARK: - Weather Data
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    @IBOutlet var humidityLabel: UILabel!
    @IBOutlet var feelsLikeLabel: UILabel!
    @IBOutlet var sunriseLabel: UILabel!
    @IBOutlet var sunsetLabel: UILabel!
    
    @IBOutlet var pageControl: UIPageControl!
    
    let locationManager = CLLocationManager()
    
    let geoCoder = CLGeocoder()
    
    var currentDay = 0
    
    var weatherManager = WeatherManager()
    
    var animationView = AnimationView()
    
    var lat = Double()
    var lon = Double()
    
    var showFavorite = false
    var favoriteLat = Double()
    var favoriteLon = Double()
    
    @IBOutlet var weatherAnimationView: UIView!
    
    override func viewDidLoad() {
        DispatchQueue.main.async {
            super.viewDidLoad()
            self.weatherManager.delegate = self
            self.locationManager.delegate = self
            self.locationManager.requestWhenInUseAuthorization()
            self.locationManager.requestLocation()
            self.addGestureRecognizer()
            self.setDetails(date: self.currentDay)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        animationView.play()
        if Reachability.isConnectedToNetwork() == false {
            showAlert()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if showFavorite == false {
        if let currentLocation = locations.last {
            lat = currentLocation.coordinate.latitude
            lon = currentLocation.coordinate.longitude
            weatherManager.fetchWeather(lat: lat, lon: lon, day: currentDay)
            geoCoder.reverseGeocodeLocation(CLLocation(latitude: lat, longitude:  lon), completionHandler: { (placemarks, _) -> Void in
                placemarks?.forEach { (placemark) in
                    if let cityData = placemark.locality, let countryData = placemark.country {
                        UIView.transition(with: self.view,duration: 0.50 ,options: .transitionCrossDissolve, animations: { [weak self] in
                            self?.cityLabel.text = cityData
                            self?.countryLabel.text = countryData
                        }, completion: nil)
                    }
                }
            })
            }
        } else {
                lat = favoriteLat
                lon = favoriteLon
                weatherManager.fetchWeather(lat: lat, lon: lon, day: currentDay)
                geoCoder.reverseGeocodeLocation(CLLocation(latitude: lat, longitude:  lon), completionHandler: { (placemarks, _) -> Void in
                    placemarks?.forEach { (placemark) in
                        if let cityData = placemark.locality, let countryData = placemark.country {
                            UIView.transition(with: self.view,duration: 0.50 ,options: .transitionCrossDissolve, animations: { [weak self] in
                                self?.cityLabel.text = cityData
                                self?.countryLabel.text = countryData
                            }, completion: nil)
                        }
                    }
                })
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    //MARK: - Hide Status Bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //MARK: - LottieFiles Function
    func startAnimation(_ name : String) {
        if weatherAnimationView != nil {
            self.animationView.removeFromSuperview()
            animationView = AnimationView(name: "LottieFiles/\(name)")
            animationView.frame = weatherAnimationView.bounds
            animationView.loopMode = .loop
            animationView.contentMode = .scaleAspectFit
            animationView.animationSpeed = 2.5
            weatherAnimationView.addSubview(animationView)
            animationView.play()
        }
    }
    
    //MARK: - Stack View Designer
    func designStackView(_ stackViewName : UIStackView?) {
        stackViewName?.backgroundColor = UIColor(white: 1.0, alpha: 0.4)
        stackViewName?.layer.cornerRadius = 30
    }
    
    func setDetails(date : Int) {
        if Reachability.isConnectedToNetwork() == false {
            showAlert()
        }
        self.setTimeOfDay()
        let currentDate = Date()
        var dateComponent = DateComponents()
        let dateFormatter = DateFormatter()
        let monthFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "EEEE"
        monthFormatter.dateFormat = "LLLL"
        
        dateComponent.day = date
        
        let futureDay = Calendar.current.date(byAdding: dateComponent, to: currentDate)
        let futureMonth = Calendar.current.date(byAdding: dateComponent, to: currentDate)
        
        let day = dateFormatter.string(from: futureDay!)
        let month = monthFormatter.string(from: futureMonth!)
        
        UIView.transition(with: self.view,duration: 0.50 ,options: .transitionCrossDissolve, animations: { [weak self] in
            self?.dayLabel.text = day
            self?.dateLabel.text = month
        }, completion: nil)
    }
    
    func addGestureRecognizer() {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeFunc(gesture:)))
        swipeRight.direction = .right
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeFunc(gesture:)))
        swipeLeft.direction = .left
        
        view.addGestureRecognizer(swipeRight)
        view.addGestureRecognizer(swipeLeft)
    }
    
    @objc func swipeFunc(gesture : UISwipeGestureRecognizer) {
        if gesture.direction == .right && currentDay >= 1 {
            currentDay -= 1
            pageControl.currentPage = currentDay
            setDetails(date: currentDay)
            if showFavorite {
                lat = favoriteLat
                lon = favoriteLon
                weatherManager.fetchWeather(lat: lat, lon: lon, day: currentDay)
            }
            else {
                weatherManager.fetchWeather(lat: lat, lon: lon, day: currentDay)
            }
            
        } else if gesture.direction == .left && currentDay < 6 {
            currentDay += 1
            pageControl.currentPage = currentDay
            setDetails(date: currentDay)
            if showFavorite {
                lat = favoriteLat
                lon = favoriteLon
                weatherManager.fetchWeather(lat: lat, lon: lon, day: currentDay)
            }
            else {
                weatherManager.fetchWeather(lat: lat, lon: lon, day: currentDay)
            }
            
        }
    }
    
    func setTimeOfDay() {
        if Reachability.isConnectedToNetwork() == false {
            showAlert()
        }
        let hour = Calendar.current.component(.hour, from: Date())
        UIView.transition(with: view,duration: 0.50 ,options: .transitionCrossDissolve, animations: { [weak self] in
            switch hour {
            case 6..<12 : self?.timeOfDayLabel.text = "Morning"
            case 12 : self?.timeOfDayLabel.text = "Noon"
            case 13..<17 : self?.timeOfDayLabel.text = "Afternoon"
            case 17..<22 : self?.timeOfDayLabel.text = "Evening"
            default: self?.timeOfDayLabel.text = "Night"
            }
        }, completion: nil)
    }
}

extension MainVC : WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.async {
            self.startAnimation(weather.conditionName)
            UIView.transition(with: self.view,duration: 0.50 ,options: .transitionCrossDissolve, animations: { [weak self] in
                self?.temperatureLabel.text = weather.tempString + "°"
                self?.weatherDescriptionLabel.text = weather.main
                self?.humidityLabel.text = String(weather.humidity)  + "%"
                self?.feelsLikeLabel.text = weather.tempFeelString  + "°"
                self?.sunriseLabel.text = String(weather.formattedSunrise.replacingOccurrences(of: "AM", with: ""))
                self?.sunsetLabel.text = String(weather.formattedSunset.replacingOccurrences(of: "PM", with: ""))
            }, completion: nil)
        }
    }
    
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: SevenDayWeatherModel) {
        DispatchQueue.main.async {
            self.startAnimation(weather.conditionName)
            UIView.transition(with: self.view,duration: 0.50 ,options: .transitionCrossDissolve, animations: { [weak self] in
                self?.temperatureLabel.text = weather.tempDayString + "°"
                self?.weatherDescriptionLabel.text = weather.main
                self?.humidityLabel.text = String(weather.humidity)  + "%"
                self?.feelsLikeLabel.text = weather.tempFeelString + "°"
                self?.sunriseLabel.text = String(weather.formattedSunrise.replacingOccurrences(of: "AM", with: ""))
                self?.sunsetLabel.text = String(weather.formattedSunset.replacingOccurrences(of: "PM", with: ""))
            }, completion: nil)
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "Caution", message: "You must have internet connection to use Weather app.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

public class Reachability {
    class func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)
        return ret
    }
}
