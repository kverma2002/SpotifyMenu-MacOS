import SwiftUI
import Combine
import SpotifyWebAPI
import SpotifyExampleContent

struct AlbumListView: View {
    
    @EnvironmentObject var vm: SpotifyDriver

    @State private var playTrackCancellable: AnyCancellable? = nil

    let index: Int
    let track: Track
    let album: Album
    
    @State private var scale = 1.5
    @Binding var alert: AlertItem?

    var body: some View {
        HStack {
            Button(action: playTrack, label: {
                    Text("\(index + 1). \(track.name)")
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .contentShape(Rectangle())
                
            })
            .buttonStyle(PlainButtonStyle())
            
            Spacer(minLength: 25)
            Button(action: playTrack, label: {
                Image("heart")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .aspectRatio(contentMode: .fit)
                    
            })
            .frame(width: 20, height: 20)
            .buttonStyle(.borderless)
            Spacer(minLength: 10)
            
            Button(action: addQ, label: {
                Image("queue")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .aspectRatio(contentMode: .fit)
            })
            .frame(width: 20, height: 20)
            .buttonStyle(.borderless)
            .scaleEffect(scale)
            .animation(.easeInOut, value: scale)
            Spacer(minLength: 30)
            
        }
        
    }
    
    func likeSongs() {
        
        
    }
    
    func addQ() {
        guard let x = track.uri else {return}
        self.playTrackCancellable = self.vm.spotify
            .addToQueue(x)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print(error.localizedDescription)
                }
            })
        
    }
    func playTrack() {
        
        let alertTitle = "Couldn't play \(track.name)"

        guard let trackURI = track.uri else {
            self.alert = AlertItem(
                title: alertTitle,
                message: "Missing data"
            )
            return
        }
        
        let playbackRequest: PlaybackRequest
        
        if let albumURI = self.album.uri {
            // Play the track in the context of its album. Always prefer
            // providing a context; otherwise, the back and forwards buttons may
            // not work.
            playbackRequest = PlaybackRequest(
                context: .contextURI(albumURI),
                offset: .uri(trackURI)
            )
        }
        else {
            playbackRequest = PlaybackRequest(trackURI)
        }

        self.playTrackCancellable = self.vm.spotify
            .play(playbackRequest)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    self.alert = AlertItem(
                        title: alertTitle,
                        message: error.localizedDescription
                    )
                    print("\(alertTitle): \(error)")
                }
            })
        
    }

}

struct AlbumListView_Previews: PreviewProvider {

    static let album = Album.abbeyRoad
    static let tracks = Album.abbeyRoad.tracks!.items

    static var previews: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(Array(tracks.enumerated()), id: \.offset) { track in
                    AlbumListView(
                        index: track.offset,
                        track: track.element,
                        album: album,
                        alert: .constant(nil)
                    )
                    Divider()
                }
            }
        }
    }
}

