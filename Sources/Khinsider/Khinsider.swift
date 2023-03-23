import SwiftSoup
import Foundation

public struct Khinsider {
  public static func latestSoundtracks() async throws -> [KHAlbum] {
    guard let page = try await content(of: URLBuilders.home()) else { throw Errors.failedToGetContent }
    let latest = try page.select("div#homepageLatestSoundtracks").first()
    let albumElements: [Element] = try latest?.select(".albumListWrapper > .albumListDiv > .albumList > tbody > tr").array() ?? []
    
    var albums: [KHAlbum] = []
    
    albumElements.forEach { element in
      if let album = try? parseTableAlbum(element) { // its probably better to ignore the error than stop parsing and throw
        albums.append(album)
      }
    }
    
    return albums
  }
  
  public static func search(_ q: String) async throws -> [KHAlbum] {
    guard let url = URLBuilders.search(q) else { throw Errors.invalidSearchQuery }
    guard let page = try await content(of: url) else { throw Errors.failedToGetContent }
    let albumElements: [Element] = try page.select(".albumListWrapper > .albumListDiv > .albumList > tbody > tr").array()
    
    var albums: [KHAlbum] = []
    
    albumElements.forEach { element in
      if let album = try? parseTableAlbum(element) { // its probably better to ignore the error than stop parsing and throw
        albums.append(album)
      }
    }
    
    return albums
  }
}
