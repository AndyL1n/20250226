//
//  BookModel.swift
//  20240226
//
//  Created by Andy on 2025/2/24.
//

import Foundation

/// 書籍 Model
struct BookModel: Codable, Hashable {
    let id: Int
    let title: String
    let author: String
    let genre: String
    let year: Int
}
