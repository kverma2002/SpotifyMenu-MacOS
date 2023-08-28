//
//  ContentView.swift
//  APITest
//
//  Created by Krit Verma on 6/27/23.
//

import SwiftUI

//
//  LoginView.swift
//  SpotMenuBar
//
//  Created by Krit Verma on 6/18/23.
//

import SpotifyWebAPI

struct ContentView: View {
    
    // Get Screen Frame
    @EnvironmentObject var vm: SpotifyDriver
    var screen = NSScreen.main?.visibleFrame
    @State var redirectURL = ""
    
    static let animation = Animation.spring()
    
    
    init(redirectURL: String = "") {
        self.redirectURL = redirectURL
    }
    

   
    
    var body: some View {
            VStack{
                
                Spacer(minLength: 0)
                
                Text("Welcome to SpotifyMenuBar")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .padding(.vertical, 10)
                
                Button(action:{vm.URLOpener()}, label: {
                    Text("Login to Spotify")
                })
                .buttonStyle(.borderedProminent)
                .padding(.vertical, 5)
                
                TextField("RedicrectURL", text: $redirectURL)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(.vertical, 10)
                    .padding(.horizontal, 40)
                
                Button(action: {vm.URLAuthorizer(queryURL: redirectURL)}, label: {
                    Text("Sumbit")
                })
                
                
                
                
                
                Spacer(minLength: 0)
                
            }
            .frame(width: 600, height: 300).background(Color.black)
            //.fixedSize(horizontal: true, vertical: true)
            
        
       
            
       
            
    }
        
    
    
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
