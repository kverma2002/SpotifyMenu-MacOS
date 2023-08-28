//
//  MenuBarNotLoggedIn.swift
//  APITest
//
//  Created by Krit Verma on 7/10/23.
//

import Foundation
import SwiftUI



import SpotifyWebAPI

struct MenuBarNotLoggedInView: View {
    
    // Get Screen Frame
    
    @EnvironmentObject var vm: SpotifyDriver

    init() {
       
    }
    
    var body: some View {
       
        VStack{
            
            Spacer(minLength: 0)
            
            Text("Please Log In first on Main App")
                .font(.largeTitle)
                .fontWeight(.heavy)
                .padding(.vertical, 10)
            
            Spacer(minLength: 0)
        }
            

            
    }
        
}


struct MenuBarViewNotLoggedIn_Previews: PreviewProvider {
    static var previews: some View {
        MenuBarNotLoggedInView()
    }
}

