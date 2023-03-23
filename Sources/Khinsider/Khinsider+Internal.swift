//
//  Khinsider+Internal.swift
//  
//
//  Created by Lakhan Lothiyi on 23/03/2023.
//

import Foundation
import SwiftSoup

extension Khinsider {
  internal static func parseTableAlbum(_ element: Element) throws -> KHAlbum? {
    guard try element.html().contains("href=") else { return nil }
    let snips = element.children()
    guard snips.count == 5 else { return nil }
    guard
      let iconStr = try? snips[0].select("img").first()?.absUrl("src"),
      let icon = URL(string: iconStr),
      let title = try? snips[1].text(),
      let urlStr = try? snips[1].select("a").first()?.absUrl("href"),
      let url = URL(string: urlStr),
      let platform = try? snips[2].text().components(separatedBy: ", "),
      let rawType = try? snips[3].text(),
      let type = KHAlbum.KHAlbumType(rawValue: rawType),
      let year = try? snips[4].text()
    else { return nil }
    
    let album = KHAlbum(title: title, icon: icon, platform: platform, type: type, year: year, url: url)
    
    return album
  }
  
  internal static func parseTableTrack(_ element: Element) throws -> KHAlbum.KHTrack? {
    let snips = Array(element.children()).filter { element in !element.hasAttr("title") }
    var disc = 1
    var track: Int
    var offset = 0
    guard let firstField = try? snips[0].text() else { return nil }
    if firstField.contains(".") {
      guard let trackNumber = Int(firstField.replacingOccurrences(of: ".", with: "")) else { return nil }
      track = trackNumber
    } else {
      guard let discNumber = Int(firstField) else { return nil }
      disc = discNumber
      guard let trackStr = try? snips[1].text(), let trackNumber = Int(trackStr.replacingOccurrences(of: ".", with: "")) else { return nil }
      track = trackNumber
      offset = 1
    }
    guard let title = try? snips[1 + offset].text() else { return nil }
    guard let timestamp = try? snips[2 + offset].text() else { return nil }
    guard
      let aElement = try? snips[1 + offset].select("a").first()?.absUrl("href"),
      let url = URL(string: aElement)
    else { return nil }

    let time = timestamp.toSeconds()
    
    let obj = KHAlbum.KHTrack(disc: disc, track: track, duration: time, title: title, url: url)

    return obj
  }
  
  internal static func content(of url: URL) async throws -> Element? {
    let (data, _) = try await URLSession.shared.data(from: url)
    guard let htmlStr = String(data: data, encoding: .utf8) else { return nil }
    let doc = try Parser.parse(htmlStr, url.absoluteString)
    let content = try doc.body()?.select("div#pageContent").first()
    return content
  }
}


extension String {
  func toSeconds() -> Int {
    let timeComponents = self.components(separatedBy: ":")
    let minutes = Int(timeComponents[0]) ?? 0
    let seconds = Int(timeComponents[1]) ?? 0
    return minutes * 60 + seconds
  }
}
