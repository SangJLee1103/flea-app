//
//  Likes.swift
//  FleaMarket
//
//  Created by 이상준 on 2023/01/08.
//

import Foundation

struct LikesModel: Decodable {
    let productId: Int
    let product: String
    let likes: [String]
    
    enum CodingKeys: String, CodingKey {
        case productId = "product_id"
        case product = "Product"
        case likes = "Likes"
    }
}
