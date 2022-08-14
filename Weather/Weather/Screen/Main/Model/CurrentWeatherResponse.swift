//
//  CurrentWeatherResponse.swift
//  Weather
//
//  Created by 소연 on 2022/08/14.
//

import Foundation

// MARK: - Weather Response

struct CurrentWeatherResponse {
    let weather: [WeatherData]
    let main: [MainData]
    
    enum CodingKeys: String, CodingKey {
        case weather
        case main
    }
}

// MARK: - Weather Data

struct WeatherData {
    let main: String
    let description: String
    let id: Int
    let icon: String
}

// MARK: - Main Data

struct MainData {
    let tempMin: Double
    let feelLike: Double
    let humidity: Int
    let pressure: Int
    let temp: Double
    let tempMax: Double
    
    enum CodingKeys: String, CodingKey {
        case tempMin = "temp_min"
        case feelLike = "feels_like"
        case humidity
        case pressure
        case temp
        case tempMax = "temp_max"
    }
}
