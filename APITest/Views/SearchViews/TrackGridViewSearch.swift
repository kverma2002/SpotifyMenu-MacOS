//import SwiftUI
import Combine
import SpotifyWebAPI
import SpotifyExampleContent
import SwiftUI

struct QueueGridItemView2: View {
    
    @EnvironmentObject var vm: SpotifyDriver
    
    /// The cover image for the album.
    let index: Int
    let track: Track
    
    
    @State private var playTrackCancellable: AnyCancellable? = nil
    
    var body: some View {
        Button(action: playTrack, label: {
            Text("\(index + 1). \(track.name) - \(String(track.artists?.first?.name ?? ""))")
                .lineLimit(1)
                .padding()
                .contentShape(Rectangle())
                .frame(maxWidth: .infinity, alignment: .leading)
            
        })
        .buttonStyle(PlainButtonStyle())
    }
    
    func playTrack() {
        guard let trackURI = track.uri else {return}
        
        let playbackRequest = PlaybackRequest(trackURI)
    
        self.playTrackCancellable = self.vm.spotify
            .play(playbackRequest)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print(error.localizedDescription)
                }
            })
        
    }
        
    
        


}

struct QueueGridItemView2_Previews: PreviewProvider {

    static let spotify = SpotifyDriver()

    static var previews: some View {
        QueueGridItemView(index: 1, track: Track.comeTogether)
            .environmentObject(spotify)
            
    }
}

