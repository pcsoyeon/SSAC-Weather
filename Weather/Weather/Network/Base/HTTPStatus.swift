//
//  NetworkResult.swift
//  Weather
//
//  Created by 소연 on 2022/08/20.
//

import Foundation

enum HTTPStatus {
    case continueStatus
    case ok
    case multipleChoice
    case badRequest
    case internalServerError
    case error
    
    init(statusCode: Int) {
        switch statusCode {
        case 100..<200 :
            self = .continueStatus
        case 200..<300:
            self = .ok
        case 300..<400:
            self = .multipleChoice
        case 400..<500:
            self = .badRequest
        case 500..<600:
            self = .internalServerError
        default:
            self = .error
        }
    }
}
