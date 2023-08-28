import SwiftUI
import Combine
import SpotifyWebAPI

struct PlaylistSingleGridView: View {
    
    @ObservedObject var vm: SpotifyDriver

    let playlist: Playlist<PlaylistItemsReference>

    /// The cover image for the playlist.
    @State private var image = Image("EmptyTrack")

    @State private var didRequestImage = false
    
    @State private var alert: AlertItem? = nil
    
    // MARK: Cancellables
    @State private var loadImageCancellable: AnyCancellable? = nil
    @State private var playPlaylistCancellable: AnyCancellable? = nil
    
    init(spotify: SpotifyDriver, playlist: Playlist<PlaylistItemsReference>) {
        self.vm = spotify
        self.playlist = playlist
    }
    
    var body: some View {
        NavigationLink(
            destination: PlaylistTrackView(playlist: playlist, image: image)
        )
        {
            VStack {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(5)
                    .padding(.trailing, 5)
                Text("\(playlist.name)")
//                if playlistDeduplicator.isDeduplicating {
//                    ProgressView()
//                        .padding(.leading, 5)
//                }
                Spacer()
            }
            .onAppear(perform: loadImage)
            // Ensure the hit box extends across the entire width of the frame.
            // See https://bit.ly/2HqNk4S
        }
        .buttonStyle(PlainButtonStyle())
        .padding(5)
        
        
//        .onReceive(playlistDeduplicator.alertPublisher) { alert in
//            self.alert = alert
//        }
    }
    
    /// Loads the image for the playlist.
    func loadImage() {
        
        // Return early if the image has already been requested. We can't just
        // check if `self.image == nil` because the image might have already
        // been requested, but not loaded yet.
        if self.didRequestImage {
            // print("already requested image for '\(playlist.name)'")
            return
        }
        self.didRequestImage = true
        
        guard let spotifyImage = playlist.images.largest else {
            // print("no image found for '\(playlist.name)'")
            return
        }

        // print("loading image for '\(playlist.name)'")
        
        // Note that a `Set<AnyCancellable>` is NOT being used so that each time
        // a request to load the image is made, the previous cancellable
        // assigned to `loadImageCancellable` is deallocated, which cancels the
        // publisher.
        self.loadImageCancellable = spotifyImage.load()
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { image in
                    // print("received image for '\(playlist.name)'")
                    self.image = image
                }
            )
    }
    
    func playPlaylist() {
        
        let playbackRequest = PlaybackRequest(
            context: .contextURI(playlist), offset: nil
        )
        self.playPlaylistCancellable = self.vm.spotify
            .play(playbackRequest)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    self.alert = AlertItem(
                        title: "Couldn't Play Playlist \(playlist.name)",
                        message: error.localizedDescription
                    )
                }
            })
        
    }
    
}

struct PlaylistCellView_Previews: PreviewProvider {

    static let spotify = SpotifyDriver()
    
    static var previews: some View {
        List {
            PlaylistSingleGridView(spotify: spotify, playlist: .thisIsMildHighClub)
            PlaylistSingleGridView(spotify: spotify, playlist: .thisIsRadiohead)
            PlaylistSingleGridView(spotify: spotify, playlist: .modernPsychedelia)
            PlaylistSingleGridView(spotify: spotify, playlist: .rockClassics)
            PlaylistSingleGridView(spotify: spotify, playlist: .menITrust)
        }
        .environmentObject(spotify)
    }
    
}
