//
//  EndPoint.swift
//  Weather
//
//  Created by 소연 on 2022/08/14.
//

import Foundation

enum EndPoint {
    case current
    case history
    case airPollution
    
    var requestURL: String {
        switch self {
        case .current:
            return URL.makeEndPointString("/weather")
        case .history:
            return URL.makeEndPointString("/history/city")
        case .airPollution:
            return URL.makeEndPointString("/air_pollution")
        }
    }
}
