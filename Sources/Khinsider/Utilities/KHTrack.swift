//
//  KHTrack.swift
//  
//
//  Created by Lakhan Lothiyi on 23/03/2023.
//

import Foundation
import SwiftSoup

extension Khinsider.KHAlbum {
  public struct KHTrack {
    public let disc: Int
    public let track: Int
    public let duration: Int
    public let title: String
    public let url: URL
  }
}


extension Khinsider.KHAlbum.KHTrack: Identifiable {
  public var id: String { self.url.absoluteString }
}


extension Khinsider.KHAlbum.KHTrack {
  public func getSourceLink(_ format: Khinsider.KHAlbum.Format) async -> URL? {
    do {
      let (data, _) = try await URLSession.shared.data(from: self.url)
      guard let htmlStr = String(data: data, encoding: .utf8) else { return nil }
      let doc = try Parser.parse(htmlStr, url.absoluteString)
      
      let link = try doc.body()?.select("#pageContent > p > a").last(where: { element in
        try element.attr("href").contains("\(format.rawValue)")
      })
      guard let urlStr = try link?.absUrl("href") else { return nil }
      
      return URL(string: urlStr)
    } catch {
      return nil
    }
  }
}
