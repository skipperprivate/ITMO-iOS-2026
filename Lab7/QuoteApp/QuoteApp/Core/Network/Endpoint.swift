//
//  Endpoint.swift
//  QuoteApp
//
//  Created by Кирилл Матвеев on 15.10.2026.
//

import Foundation

struct Endpoint {
    enum HTTPMethod: String { case get = "GET" }
    
    let path: String
    var method: HTTPMethod = .get
    var queryItems: [URLQueryItem] = []
}
