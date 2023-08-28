//
//  NavControllerView.swift
//  APITest
//
//  Created by Krit Verma on 7/19/23.
//

import Foundation
import SwiftUI

struct Option: Hashable {
    let title: String
    let imageName: String
}


struct ControllerView: View {
    @State var currentOption = 0
    @EnvironmentObject var vm: SpotifyDriver
    
    
    let options: [Option] = [
        .init(title:"Queue", imageName: "queue"),
        .init(title:"Search", imageName: "search"),
        .init(title:"Playlists", imageName: "playlistBlack"),
        .init(title:"Albums", imageName: "albumBlack"),
    ]
    var body: some View {
        if (vm.authrorized) {
            VStack{
                NavigationView {
                    ListView(options: options,
                             currentSelection: $currentOption)
                    
                    switch currentOption {
                    case 0:
                        QueueView()
                    case 1:
                        SearchView()
                    case 2:
                        PlaylistView()
                    case 3:
                        SavedAlbumsView()
                    default:
                        MainView()
                    }
                    
                    EmptyView()
                        .frame(width: 300)
                }
                MenuBarView()
            }
            .frame(width: 800, height: 600)
            
        }
        else {
            ContentView()
        }
       
    }
    
    
    
}

struct ListView: View {
    let options: [Option]
    @Binding var currentSelection: Int
    
    var body: some View {
        VStack {
            let current = options[currentSelection]
            ForEach(options, id: \.self) { option in
                HStack {
                    Image(option.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30)
                    Text(option.title)
                        .foregroundColor(current == option ?
                                         Color(.green) : Color.white)
                    Spacer()
                }
                .padding()
                .onTapGesture {
                    if option.title == "Queue" {
                                            currentSelection = 0
                                        } else if option.title == "Search" {
                                            currentSelection = 1
                                        } else if option.title == "Playlists" {
                                            currentSelection = 2
                                        } else {
                                            currentSelection = 3
                                        }
                }
            }
        }
        Spacer()
    }
}

struct MainView: View {
    var body: some View {
        Text("Poggers")    }
}

struct PlayerView: View {
    var body: some View {
        Text("Poopers")
    }
}
struct ControllerView_Preview: PreviewProvider {
    static var previews: some View {
        ControllerView()
    }
}
