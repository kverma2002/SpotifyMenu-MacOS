//
//  MenuBarView.swift
//  APITest
//
//  Created by Krit Verma on 7/10/23.
//

import SwiftUI

import Combine

import SpotifyWebAPI

struct MenuBarView: View {
    
    // Get Screen Frame
    
    @EnvironmentObject var vm: SpotifyDriver
    @State private var queue = SpotifyQueue.sampleQueue
    
    @State private var alert: AlertItem? = nil
    
    //Queue variables
    @State private var didRequestQueue = false
    @State private var isLoadingQueue = false
    @State private var couldntLoadQueue = false
    @State private var itterableQueue: [PlaylistItem] = []
    @State private var loadQueueCancellables: AnyCancellable? = nil
    
    //Current Playing Context Variables
    @State private var loadCurrentCancellables: AnyCancellable? = nil
    @State private var name = ""
    @State private var playing: CurrentlyPlayingContext?
    @State private var gotPlaying = false
    
    //Play Buttons Variables
    @State var shuffle = false
    @State var rep = false
    @State private var loadPlayerCancellables: AnyCancellable? = nil
    
    let columns = [
        GridItem(.adaptive(minimum: 100, maximum: 200))
    ]
    
    init() {
    }
    
    
    var body: some View {
        Group {
            
            HStack {
                refresh
                VStack {
                    Text(self.name)
                        .font(.custom("AmericanTypewriter", size: 10))
                        .padding(.vertical, 8)
                }
                
                HStack {
                    Button(action: {
                        self.toggleShuffle()
                    }, label: {
                        Image(self.shuffle == true ? "shuffleOn" : "shuffle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width:50, height: 50)
                        
                    })
                    .frame(width:50, height:50)
                    .buttonStyle(.borderless)
                    
                    Button(action: {
                        self.back()
                    }, label: {
                        Image("back")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width:50, height: 50)
                        
                    })
                    .frame(width:50, height:50)
                    .buttonStyle(.borderless)
                    
                    
                    
                    Button(action: {
                        self.togglePlay()
                    }, label: {
                        Image(vm.playing == true ? "play" : "pause")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width:50, height: 50)
                        
                    })
                    .frame(width:50, height:50)
                    .buttonStyle(.borderless)
                    
                    Button(action: {
                        self.skip()
                    }, label: {
                        Image("forward")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width:50, height: 50)
                        
                    })
                    .frame(width:50, height:50)
                    .buttonStyle(.borderless)
                    
                    Button(action: {
                        self.toggleRepeat()
                    }, label: {
                        Image(self.rep == true ? "repeatOn" : "repeat")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width:50, height: 50)
                        
                    })
                    .frame(width:50, height:50)
                    .buttonStyle(.borderless)
                }
                
                
                
            }
            .frame(width: 800, height: 60)
            
        }
        .onAppear(perform: getPlaying)
    
    }
    
    var refresh: some View {
        Button(action: getPlaying, label: {
            Image(systemName: "arrow.clockwise")
                .font(.title)
                .scaleEffect(0.8)
        }).buttonStyle(.borderless)
    }
    
    func displayUserName() -> String {
        if(!vm.authrorized) {
            return "User"
        }
        else {
            return vm.currentUser?.displayName ?? "User"
        }
    }
    
    func skip() {
        loadPlayerCancellables = self.vm.spotify.skipToNext()
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completiion in
                print("Great Skip")
                if case .failure(let error) = completiion {
                    print(error.localizedDescription)
                }
            })
        self.loadQueue()
    }
    
    func back() {
        loadPlayerCancellables = self.vm.spotify.skipToNext()
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completiion in
                print("Great Back")
                if case .failure(let error) = completiion {
                    print(error.localizedDescription)
                }
            })
        self.loadQueue()
        
    }
    
    func toggleShuffle() {
        // Copy to main
        if (self.shuffle == false) {
            loadPlayerCancellables = vm.spotify.setShuffle(to: true)
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { completiion in
                    print("Great REPEAT ON")
                    if case .failure(let error) = completiion {
                        print(error.localizedDescription)
                    }
            })
            self.shuffle = true
        }
        else {
            loadPlayerCancellables = vm.spotify.setShuffle(to: false)
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { completiion in
                    print("Great Repeat OFF")
                    if case .failure(let error) = completiion {
                        print(error.localizedDescription)
                    }
            })
            self.shuffle = false
        }
        
    }
    
    func toggleRepeat() {
        if (self.rep == false) {
            loadPlayerCancellables = vm.spotify.setRepeatMode(to: RepeatMode.context)
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { completiion in
                    print("Great REPEAT ON")
                    if case .failure(let error) = completiion {
                        print(error.localizedDescription)
                    }
            })
            self.rep = true
        }
        else {
            loadPlayerCancellables = vm.spotify.setRepeatMode(to: RepeatMode.off)
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { completiion in
                    print("Great Repeat OFF")
                    if case .failure(let error) = completiion {
                        print(error.localizedDescription)
                    }
            })
            self.rep = false
        }
        
    }
    
    func togglePlay() ->Void {
        print("Poggies")
        print(vm.playing)
        if (vm.playing) {
            loadPlayerCancellables = self.vm.spotify.pausePlayback(/*deviceId: vm.device*/)
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { completiion in
                    print("Great Pause")
                    if case .failure(let error) = completiion {
                        print(error.localizedDescription)
                    }
                })
            
            vm.playing = false
        }
        else {
            loadPlayerCancellables = self.vm.spotify.resumePlayback(/*deviceId: vm.device*/)
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { completiion in
                    print("Great Resume")
                    if case .failure(let error) = completiion {
                        print(error.localizedDescription)
                    }
                })
            vm.playing = true
            
        }
        print(vm.playing)
        
    }
    
    func getPlaying() {
        
        if(!vm.authrorized) {
            print("Not authorized yet")
        }
        else {
            print("Getting CurrentPlayback")
            self.loadQueueCancellables = vm.spotify
                .currentPlayback()
                .receive(on: RunLoop.main)
                .sink(
                    receiveCompletion: { completion in
                        self.isLoadingQueue = false
                        switch completion {
                        case .finished:
                                self.couldntLoadQueue = false
                            case .failure(let error):
                                self.couldntLoadQueue = true
                                
                        }
                    },
                    receiveValue: { playbackContext in
                        let temp = playbackContext
                        self.playing = temp
                        self.gotPlaying = true
                        name = self.playing?.item!.name ?? ""
                        //self.play = ((playbackContext?.isPlaying) != nil)
                        //print(self.play)
                        //print(playing)
                    }
                )
        }
        
    }
    
    func loadQueue() {
        if(!vm.authrorized) {
            print("Not authorized yet")
        }
        else {
            self.isLoadingQueue = true
            self.itterableQueue = []
            self.didRequestQueue = true
            
            print("Getting queue")
            
            self.loadQueueCancellables = vm.spotify
                .queue()
                .receive(on: RunLoop.main)
                .sink(
                    receiveCompletion: { completion in
                        self.isLoadingQueue = false
                        switch completion {
                            case .finished:
                                self.couldntLoadQueue = false
                            case .failure(let error):
                                self.couldntLoadQueue = true
                                
                        }
                    },
                    receiveValue: { savedQueue in
                        let temp = savedQueue.queue
                        self.itterableQueue = temp
                        //print(savedQueue.currentlyPlaying?.name)
                        //print(savedQueue.queue)
                        //print("1")
                        
                    }
                )
        }
        
    }
    
        
}


struct MenuBarView_Previews: PreviewProvider {
    
    static var spotify = SpotifyDriver()
    
    
    
    static var previews: some View {
        MenuBarView().environmentObject(spotify)
    }
}

