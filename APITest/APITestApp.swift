//
//  APITestApp.swift
//  APITest
//
//  Created by Krit Verma on 6/27/23.
//

import SwiftUI
import SpotifyWebAPI
import Cocoa
import KeyboardShortcuts


@main
struct APITestApp: App {
    
    @NSApplicationDelegateAdaptor var Appdel: AppDelegate
    
    //@StateObject var vm = SpotifyDriver()
    
    init() {
        //SpotifyAPILogHandler.bootstrap()
    }
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
        
        
    }

    
    
}


