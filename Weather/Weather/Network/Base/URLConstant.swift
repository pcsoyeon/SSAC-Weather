//
//  URLConstant.swift
//  Weather
//
//  Created by 소연 on 2022/08/13.
//

import Foundation

struct URLConstant {
    static let BaseURL = "https://api.openweathermap.org/data/2.5"
}

extension URL {
    static let BaseURL = "https://api.openweathermap.org/data/2.5"
    
    static func makeEndPointString(_ endPoint: String) -> String {
        return BaseURL + endPoint
    }
}
