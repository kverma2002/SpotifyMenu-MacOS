

import Foundation

struct SongImage: Decodable {
    let url: String
}

struct Album: Decodable {
    let images: [SongImage]
    let name: String
}

struct Astists: Decodable {
    let name: String
}

struct TrackObject: Decodable {
    let album: Album
    let artists: [Astists]
    let name: String
}



struct PlayerCurrentAndQueue: Decodable {
    let currently_playing: TrackObject
    let queue: [TrackObject]
    
}

