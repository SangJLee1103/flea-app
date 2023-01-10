//
//  LankingData.swift
//  FleaMarket
//
//  Created by 이상준 on 2022/06/04.

struct ProductRankingModel: Decodable {
    let id: Int
    let productImg: String
    let productName: String
    let sellerName: String
    let price: Int
    let likesCount: Int
    
    enum CodingKeys: String, CodingKey {
        case likesCount
        case id = "product_id"
        case productImg = "img"
        case productName = "name"
        case sellerName = "nickname"
        case price = "selling_price"
    }
}

struct RankArray: Decodable {
    let data: [ProductRankingModel]
}
