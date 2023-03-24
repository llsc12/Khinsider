//
//  KHAlbum.swift
//  
//
//  Created by Lakhan Lothiyi on 23/03/2023.
//

import Foundation
import SwiftSoup

extension Khinsider {
  public struct KHAlbum {
    public let title: String
    public let icon: URL
    public let platform: [String]
    public let type: KHAlbumType
    public let year: String
    
    public let url: URL
    
    public enum KHAlbumType: String {
      case gamerip = "Gamerip"
      case soundtrack = "Soundtrack"
      case single = "Single"
      case compilation = "Compilation"
      case arrangement = "Arrangement"
      case remix = "Remix"
      case unknown = ""
    }
  }
}

// conform to Identifiable so its usable in swiftui
extension Khinsider.KHAlbum: Identifiable {
  public var id: String {
    self.url.absoluteString
  }
}

// adds utility methods to the struct so you can get songs and stuff
extension Khinsider.KHAlbum {
  public enum Format: String, CaseIterable {
    case mp3 = "mp3"
    case flac = "flac"
  }
  
  internal var page: Element? {
    get async throws {
      try await Khinsider.content(of: self.url)
    }
  }
  
  public var availableFormats: [Format] {
    get async throws {
      var formats = [Format]()
      guard let page = try await self.page else { return formats }
      guard let header = try? page.select("table#songlist").first()?.select("#songlist_header").first() else { return formats }
      for format in Format.allCases {
        if ((try? header.html()) ?? "").lowercased().contains(format.rawValue.lowercased()) {
          formats.append(format)
        }
      }
      
      return formats
    }
  }
  
  public var tracks: [KHTrack] {
    get async throws {
      guard let page = try await self.page else { return [] }
      guard let trackTableItems = try? page.select("table#songlist").first()?.select("tr").filter({ egg in !egg.hasAttr("id") }) else { return [] }
      
      var trackObjs = [KHTrack]()
      for track in trackTableItems {
        if let tr = try? Khinsider.parseTableTrack(track) {
          trackObjs.append(tr)
        }
      }
      
      return trackObjs
    }
  }
}

extension Khinsider.KHAlbum {
  public func allSourceLinks(_ format: Khinsider.KHAlbum.Format) async throws -> [URL]? {
    let dlUrls = await withTaskGroup(of: URL?.self) { group in
      try? await self.tracks.forEach { track in
        group.addTask {
          return await track.getSourceLink(format)
        }
      }
      
      var collected = [URL]()
      
      for await value in group {
        if let value {
          collected.append(value)
        }
      }
      
      return collected
    }
    
    return dlUrls
  }
}
