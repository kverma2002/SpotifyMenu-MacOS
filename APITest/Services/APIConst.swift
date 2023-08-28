//
//  APIConst.swift
//  SpotMenuBar
//
//  Created by Krit Verma on 6/25/23.
//

import Foundation

enum APIConstants {
    static let apiHost = "api.spotify.com"
    static let authHost = "accounts.spotify.com"
    static let clientId = "yourClinetID"
    static let clientSecret = "yourClientSecret"
    static let redirectURL = "your redirect url"
    static let responseType = "token"
    static let scopes = "user-read-private"
    
    static var authParams = [
        "response_type": responseType,
        "client_id": clientId,
        "redirect_url": redirectURL,
        "scope": scopes
    ]
}

