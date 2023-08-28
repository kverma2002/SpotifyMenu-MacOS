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

struct LoggedInView: View {
    
    // Get Screen Frame
    
    @EnvironmentObject var vm: SpotifyDriver
    
    var screen = NSScreen.main?.visibleFrame
    @State var redirectURL = ""
    
    
    
    init(redirectURL: String = "") {
       
    }
    

   
    
    var body: some View {
        if (vm.authrorized) {
            VStack{
                
                Spacer(minLength: 0)
                
                Text("Welcome \(displayUserName())")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .padding(.vertical, 10)
                
                Spacer(minLength: 0)
                
            }.frame(maxWidth:.infinity, maxHeight:  .infinity).background(Color.black)
        }
        else {
            ContentView()
        }
        
            
            
       
            
       
            
    }
    
    func displayUserName() -> String {
        if(!vm.authrorized) {
            return "User"
        }
        else {
            return vm.currentUser?.displayName ?? "User"
        }
    }
        
    
    
}

struct LoggedInView_Previews: PreviewProvider {
    static var previews: some View {
        LoggedInView()
    }
}

