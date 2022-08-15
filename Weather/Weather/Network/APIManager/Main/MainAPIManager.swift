//
//  MainAPIManager.swift
//  Weather
//
//  Created by 소연 on 2022/08/13.
//

import Foundation
import CoreLocation

import Alamofire
import SwiftyJSON

class MainAPIManager {
    
    static let shared = MainAPIManager()
    
    private init() { }
    
    // MARK: - Current Weather Data
    
    func fetchCurrentWeather(latitude: Double, longtitude: Double, completionHandler: @escaping ([WeatherData], (MainData)) -> ()) {
        let url = EndPoint.current.requestURL + "?lat=\(latitude)&lon=\(longtitude)&appid=\(APIKey.OpenWeather)&lang=kr"
        
        AF.request(url, method: .get).validate(statusCode: 200...500).responseData { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                
                let statusCode = response.response?.statusCode ?? 500
                if statusCode == 200 {
                    let weatherList: [WeatherData] = json["weather"].arrayValue.map {
                        WeatherData(main: $0["main"].stringValue,
                                    description: $0["description"].stringValue,
                                    id: $0["id"].intValue,
                                    icon: $0["icon"].stringValue)
                    }
                    
                    let mainData = MainData(tempMin: json["main"]["temp_min"].doubleValue,
                                            feelLike: json["main"]["feels_like"].doubleValue,
                                            humidity: json["main"]["humidity"].intValue,
                                            pressure: json["main"]["pressure"].intValue,
                                            temp: json["main"]["temp"].doubleValue,
                                            tempMax: json["main"]["temp_max"].doubleValue)
                    
                    completionHandler(weatherList, mainData)
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    // MARK: - Weather History Data
    
    func fetchWeatherHistory(latitude: Double, longtitude: Double, completionHandler: @escaping (Double) -> ()) {
        let url = EndPoint.current.requestURL + "?lat=\(latitude)&lon=\(longtitude)&appid=\(APIKey.OpenWeather)"
        
        AF.request(url, method: .get).validate(statusCode: 200...500).responseData { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                
                let statusCode = response.response?.statusCode ?? 500
                if statusCode == 200 {
                    let temp = json["main"]["temp"].doubleValue
                    completionHandler(temp)
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
}
