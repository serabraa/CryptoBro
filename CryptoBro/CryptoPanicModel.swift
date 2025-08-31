//
//  CryptoPanicModel.swift
//  CryptoBro
//
//  Created by Sergey on 23.08.25.
//

import Foundation

import Foundation

struct CryptoPanicResponse: Codable {
    let results: [NewsPost]
}

struct NewsPost: Identifiable, Codable {
    let id: Int
    let title: String
    let url: String?
    
    enum CodingKeys: String, CodingKey {
        case id, title, url
    }
}
