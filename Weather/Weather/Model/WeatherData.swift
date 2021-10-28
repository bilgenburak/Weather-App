//
//  WeatherData.swift
//  Weather
//
//  Created by Burak on 26.10.2021.
//

import Foundation

struct WeatherData : Codable {
    let current : Current
    let timezone : String
}

struct Current : Codable {
    let weather : [Weather]
    let sunrise : Int
    let sunset : Int
    let temp : Double
    let humidity : Int
    let feels_like : Double
}

struct Weather : Codable {
    let id : Int
    let main : String
}

struct SevenDayWeatherData : Codable {
    let daily : [Daily]
    let timezone : String
}

struct Daily : Codable {
    let dt : Int
    let sunrise : Int
    let sunset : Int
    let temp : Temp
    let feels_like : Feels_Like
    let humidity : Int
    let weather : [Weather]
}

struct Temp : Codable {
    let day : Float
}

struct Feels_Like : Codable {
    let day : Float
}
