//
//  SwiftUIView.swift
//  APITest
//
//  Created by Krit Verma on 7/19/23.
//

import SwiftUI
import Combine
import SpotifyWebAPI

struct QueueView: View {
    @EnvironmentObject var vm: SpotifyDriver
    
    @State private var loadTracksCancellable: AnyCancellable? = nil
    @State private var playQueueCancellable: AnyCancellable? = nil
    
    @State private var isLoadingTracks = false
    @State private var couldntLoadTracks = false
    
    @State var allTracks: [Track] = []

    
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                Text("Your Queue")
                    .font(.title)
                    .bold()
                    .padding(.horizontal)
                    .padding(.top, -10)
                if allTracks.isEmpty {
                    Group {
                        if isLoadingTracks {
                            HStack {
                                ProgressView()
                                    .padding()
                                Text("Loading Tracks")
                                    .font(.title)
                                    .foregroundColor(.secondary)
                            }
                        }
                        else if couldntLoadTracks {
                            Text("Couldn't Load Tracks")
                                .font(.title)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 20)
                }
                else {
                    ForEach(
                        Array(allTracks.enumerated()),
                        id: \.offset
                    ) { track in
                        QueueGridItemView(
                            index: track.offset,
                            track: track.element
                        )
                        Divider()
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Queue")
        .toolbar {
            refreshButton
        }
        .onAppear(perform: loadQueue)
    }
    
    var refreshButton: some View {
        
        Button(action: loadQueue) {
            Image(systemName: "arrow.clockwise")
                .font(.title)
                .scaleEffect(0.8)
        }
        
    }
    
    func loadQueue() {
        
        self.isLoadingTracks = true
        self.allTracks = []
        self.loadTracksCancellable = self.vm.spotify
            .queue()
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { completion in
                    self.isLoadingTracks = false
                    switch completion {
                        case .finished:
                            self.couldntLoadTracks = false
                        case .failure(let error):
                            self.couldntLoadTracks = true
                            print(error.localizedDescription)
                    }
                },
                receiveValue: { savedAlbums in
                    for x in savedAlbums.queue {
                        
                        if case .track(let track) = x {
                            if track.isLocal { continue }
                            else {  allTracks.append(track) }
                        }
                        
                    }
                    
                    
                }
            )
    }
}

struct QueueView_Previews: PreviewProvider {
    static var previews: some View {
        QueueView()
    }
}
