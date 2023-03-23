import XCTest
@testable import Khinsider

final class KhinsiderTests: XCTestCase {
  func testHome() async throws {
    let _ = try await Khinsider.latestSoundtracks()
  }
  
  func testSearch() async throws {
    let albums = try await Khinsider.search("kirby")
    albums.forEach { album in
      print(album.title)
    }
  }
  
  func testAlbumTracks() async throws {
    let album = try await Khinsider.search("kirby").first!
    let formats = try await album.availableFormats
    let tracks = try await album.tracks
    
    var str = ""
    formats.forEach { format in
      str += format.rawValue
      str += " "
    }
    
    print("[\(album.title)] \(album.url)")
    print("[Album Formats] \(str)")
    print("[Album] \(tracks.count) tracks.")
    for track in tracks {
      print("\(track.disc) - \(track.track). \(track.title)")
    }
    
    if let gm = try? await album.allSourceLinks(.flac) {
      print(gm)
    }
  }
}
