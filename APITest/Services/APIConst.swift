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
    static let clientId = "481c96d7c7c04f3e8b8c246a0368e5a1"
    static let clientSecret = "a304f550508d4416a72deac22178998e"
    static let redirectURL = "https://www.google.com"
    static let responseType = "token"
    static let scopes = "user-read-private"
    
    static var authParams = [
        "response_type": responseType,
        "client_id": clientId,
        "redirect_url": redirectURL,
        "scope": scopes
    ]
}

