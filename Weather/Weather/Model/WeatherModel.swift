//
//  WeatherModel.swift
//  Weather
//
//  Created by Burak on 26.10.2021.
//

import Foundation

struct WeatherModel {
    let conditionID : Int
    let main : String
    let sunrise : Int
    let sunset : Int
    let temp : Double
    let humidity : Int
    let feelsLike : Double
    let timezone : String
    
    var tempString : String {
        return String(format: "%.1f", temp)
    }
    
    var tempFeelString : String {
        return String(format: "%.1f", feelsLike)
    }
    
    var formattedSunrise : String {
        let date = Date(timeIntervalSince1970: Double(sunrise))
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.short
        dateFormatter.timeZone = TimeZone(identifier: timezone)
        let localDate = dateFormatter.string(from: date)
        return localDate
    }
    
    var formattedSunset : String {
        let date = Date(timeIntervalSince1970: Double(sunset))
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.short
        dateFormatter.timeZone = TimeZone(identifier: timezone)
        let localDate = dateFormatter.string(from: date)
        return localDate
    }
    
    var conditionName : String {
        switch conditionID {
        case 200...232: return "cloud.bolt"
        case 300...321: return "cloud.drizzle"
        case 500...531: return "cloud.rain"
        case 600...622: return "cloud.snow"
        case 701...781: return "cloud.fog"
        case 800: return "sun.max"
        case 801...804: return "cloud.normal"
        default: return "cloud"
        }
    }
}

struct SevenDayWeatherModel {
    let dt : Int
    let sunrise : Int
    let sunset : Int
    let tempDay : Float
    let feelDay : Float
    let humidity : Int
    let id : Int
    let main : String
    let timezone : String
    var tempDayString : String {
        return String(format: "%.1f", tempDay)
    }
    
    var tempFeelString : String {
        return String(format: "%.1f", feelDay)
    }
    
    var formattedSunrise : String {
        let date = Date(timeIntervalSince1970: Double(sunrise))
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.short
        dateFormatter.timeZone = TimeZone(identifier: timezone)
        let localDate = dateFormatter.string(from: date)
        return localDate
    }
    
    var formattedSunset : String {
        let date = Date(timeIntervalSince1970: Double(sunset))
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.short
        dateFormatter.timeZone = TimeZone(identifier: timezone)
        let localDate = dateFormatter.string(from: date)
        return localDate
    }
    
    var conditionName : String {
        switch id {
        case 200...232: return "cloud.bolt"
        case 300...321: return "cloud.drizzle"
        case 500...531: return "cloud.rain"
        case 600...622: return "cloud.snow"
        case 701...781: return "cloud.fog"
        case 800: return "sun.max"
        case 801...804: return "cloud.normal"
        default: return "cloud"
        }
    }
}
