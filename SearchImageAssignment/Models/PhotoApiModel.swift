//
//  PhotoApiModel.swift
//  SearchImageAssignment
//
//  Created by shashant on 08/05/22.
//

import Foundation

// MARK: - Welcome
struct PhotoAPIModel: Codable {
    let total, totalPages: Int?
    let results: [results]?

    enum CodingKeys: String, CodingKey {
        case total
        case totalPages = "total_pages"
        case results
    }
}

// MARK: - Result
struct results: Codable {
    let id: String?
    let urls: Urls?
  

    enum CodingKeys: String, CodingKey {
        case id
        case urls
    }
}

// MARK: - Urls
struct Urls: Codable {
    let raw, full, regular, small: String?
    let thumb, smallS3: String?

    enum CodingKeys: String, CodingKey {
        case raw, full, regular, small, thumb
        case smallS3 = "small_s3"
    }
}
