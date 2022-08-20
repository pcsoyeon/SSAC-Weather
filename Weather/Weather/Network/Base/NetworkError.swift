//
//  NetworkError.swift
//  Weather
//
//  Created by 소연 on 2022/08/20.
//

import Foundation

enum NetworkError: Error {
    case versionError
    case invalidURL
    case invalidResponse
    case parsingError
    case invalidRequest
    case serverError
    case unknown
}
