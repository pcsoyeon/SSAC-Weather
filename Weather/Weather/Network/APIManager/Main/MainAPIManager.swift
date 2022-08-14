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
    
    typealias completionHandler = (JSON) -> ()
    
    func fetchWeatherData(latitude: Double, longtitude: Double, completionHandler: @escaping completionHandler) {
        let url = URLConstant.BaseURL + "/weather?lat=\(latitude)&lon=\(longtitude)&appid=\(APIKey.OpenWeather)"
        
        AF.request(url, method: .get).validate(statusCode: 200...500).responseData { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                
                let statusCode = response.response?.statusCode ?? 500
                
                switch statusCode {
                case 200:
                    completionHandler(json)
                case 400..<500:
                    print("CLIENT ERROR")
                case 500...600:
                    print("SEVER ERROR")
                default:
                    print("")
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
}
