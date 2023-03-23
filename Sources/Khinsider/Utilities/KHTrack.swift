//
//  KHTrack.swift
//  
//
//  Created by Lakhan Lothiyi on 23/03/2023.
//

import Foundation

extension Khinsider.KHAlbum {
  struct KHTrack {
    let disc: Int
    let track: Int
    let duration: Int
    let title: String
    let url: URL
  }
}


extension Khinsider.KHAlbum.KHTrack: Identifiable {
  var id: String { self.url.absoluteString }
}
