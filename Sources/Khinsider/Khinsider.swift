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
  
  public static func album(from url: URL) async throws -> KHAlbum? {
    guard let page = try await content(of: url) else { throw Errors.failedToGetContent }
    guard
      let pInfoElement = page.children().first(where: { element in
        element.hasAttr("align")
      }),
      let albumIconStr = try? page.select(".albumImage > a").first()?.absUrl("href"),
      let albumIcon = URL(string: albumIconStr),
      let title = try? page.children().select("h2").first()?.text()
    else { return nil }
    
    var platforms: [String]
    var platformElements: [Element] = []
    for (i, gm) in pInfoElement.children().enumerated() {
      if i < (pInfoElement.children().firstIndex(where: {gm in gm.description.contains("br")}) ?? 0) {
        platformElements.append(gm)
      }
    }
    
    platforms = platformElements.compactMap({ gm in
      try? gm.text()
    })
    
    var type: KHAlbum.KHAlbumType = .unknown
    let _ = pInfoElement.children().lastIndex(where: { element in
      if let text = try? element.text().capitalized {
        if let foundType = KHAlbum.KHAlbumType.init(rawValue: text) {
          type = foundType
          return true
        }
      }
      return false
    })
    
    let year: String = {
      (try? pInfoElement.select("b").first()?.text()) ?? "Unknown"
    }()
    
    let obj = KHAlbum(title: title, icon: albumIcon, platform: platforms, type: type, year: year, url: url)
    
    return obj
  }
}
