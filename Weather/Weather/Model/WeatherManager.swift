//
//  WeatherManager.swift
//  Weather
//
//  Created by Burak on 26.10.2021.
//

import Foundation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: SevenDayWeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    var delegate : WeatherManagerDelegate?
    
    let apiUnit = "metric"
    let apiKey = "YOU_MUST_GET_YOUR_OWN_API_KEY"
    let apiURL = "https://api.openweathermap.org/data/2.5/onecall?"
    
    func fetchWeather(lat : Double, lon : Double, day : Int) {
        let urlString = "\(apiURL)appid=\(apiKey)&units=\(apiUnit)&lat=\(lat)&lon=\(lon)"
        performRequest(urlString, day: day)
    }
    
    func performRequest(_ urlString : String, day : Int) {
        if let URL = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: URL) { data, response, error in
                if let errorMessage = error {
                    self.delegate?.didFailWithError(error: errorMessage)
                    return
                }
                if let safeData = data {
                    if day == 0 {
                        if let weather = parseFirstJSON(safeData) {
                            self.delegate?.didUpdateWeather(self, weather: weather)
                        }
                    } else {
                        if let secondWeather = parseSecondJSON(safeData, day: day) {
                            self.delegate?.didUpdateWeather(self, weather: secondWeather)
                        }
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseFirstJSON(_ weatherData : Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let weatherID = decodedData.current.weather[0].id
            let main = decodedData.current.weather[0].main
            let sunrise = decodedData.current.sunrise
            let sunset = decodedData.current.sunset
            let temp = decodedData.current.temp
            let humidity = decodedData.current.humidity
            let feelsLike = decodedData.current.feels_like
            let timezone = decodedData.timezone
            let weather = WeatherModel(conditionID: weatherID, main: main, sunrise: sunrise, sunset: sunset, temp: temp, humidity: humidity, feelsLike: feelsLike, timezone: timezone)
            return weather
        } catch {
            self.delegate?.didFailWithError(error : error)
            return nil
        }
    }
    
    func parseSecondJSON(_ sevenWeatherData : Data, day : Int) -> SevenDayWeatherModel? {
        let decoder = JSONDecoder()
        do {
            let otherDecodedData = try decoder.decode(SevenDayWeatherData.self, from: sevenWeatherData)
            let dt = otherDecodedData.daily[day].dt
            let otherSunrise = otherDecodedData.daily[day].sunrise
            let otherSunset = otherDecodedData.daily[day].sunset
            let tempDay = otherDecodedData.daily[day].temp.day
            let feelDay = otherDecodedData.daily[day].feels_like.day
            let otherHumidity = otherDecodedData.daily[day].humidity
            let otherID = otherDecodedData.daily[day].weather[0].id
            let otherMain = otherDecodedData.daily[day].weather[0].main
            let timezone = otherDecodedData.timezone
            let otherWeather = SevenDayWeatherModel(dt: dt, sunrise: otherSunrise, sunset: otherSunset, tempDay: tempDay, feelDay: feelDay, humidity: otherHumidity, id: otherID, main: otherMain, timezone: timezone)
            return otherWeather
        } catch {
            self.delegate?.didFailWithError(error : error)
            return nil
        }
    }
}
