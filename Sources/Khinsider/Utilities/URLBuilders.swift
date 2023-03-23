//
//  URLBuilders.swift
//  
//
//  Created by Lakhan Lothiyi on 23/03/2023.
//

import Foundation

extension Khinsider {
  struct URLBuilders {
    static func home() -> URL { URL(string: "https://downloads.khinsider.com")! }
    static func search(_ q: String) -> URL? {
      var search = URLComponents(string: "https://downloads.khinsider.com/search")!
      search.queryItems = [URLQueryItem(name: "search", value: q)]
      return search.url
    }
  }
}
