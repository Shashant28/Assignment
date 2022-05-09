//
//  APIUrls.swift
//  SearchImageAssignment
//
//  Created by shashant on 08/05/22.
//

import Foundation

class CurrentPage {
    private var pageNum :Int = 0
    static var currentPage = CurrentPage()
    
    func getPageNum() -> String {
        self.pageNum += 1
        return "\(self.pageNum)"
    }
}

enum APICredential:String {
    case Basepath = "api.unsplash.com"
    case AccessKey = "--En17Q9NmhzHwqjuHRUBXENgWR9XubY1ksLtaIpqfs"
}

enum APIEndPoints:String {
    case Getphoto = "/search/photos"
}




struct EndPoints {
    let path:String
    let queryItems:[URLQueryItem]
}

extension EndPoints {
    static func search(matching query: String,isNew:Bool) -> EndPoints {
           return EndPoints(
            path: APIEndPoints.Getphoto.rawValue,
               queryItems: [
                   URLQueryItem(name: "query", value: query),
                   URLQueryItem(name: "client_id", value: APICredential.AccessKey.rawValue),
                   URLQueryItem(name: "page", value: isNew ? "\(1)" : CurrentPage.currentPage.getPageNum())
               ]
           )
    }
}

extension EndPoints {
    var url: URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = APICredential.Basepath.rawValue
        components.path = path
        components.queryItems = queryItems

        return components.url
    }
}
