//
//  Product.swift
//  FleaMarket
//
//  Created by 이상준 on 2022/06/04.
//
import Foundation
import UIKit

struct ProductModel: Decodable {
    let id: Int
    let img: String // 이미지 경로
    let name: String // 상품명
    let userId: String // 판매자 메일
    let sellingPrice: Int // 판매 가격
    let description: String // 상품 상세 설명
    let createdAt: String // 생성날짜
    let costPrice: Int // 시가
    let boardId: Int // 게시글 아이디
    let boardTitle: String
    let user: Seller
    let likes: [Likes] // 좋아요
    let board: Board?
    
    enum CodingKeys: String, CodingKey {
        case id, img, name, description
        case userId = "user_id"
        case sellingPrice = "selling_price"
        case costPrice = "cost_price"
        case createdAt = "created_at"
        case boardId = "board_id"
        case boardTitle = "board_title"
        case user = "User"
        case likes = "Likes"
        case board = "Board"
    }
}

struct Seller: Decodable {
    let nickname: String
}

struct Board: Decodable {
    let place: String
    let start: String
}

struct Likes: Decodable {
    let productId: Int
    
    enum CodingKeys: String, CodingKey {
        case productId = "product_id"
    }
}

struct ProductArray: Decodable {
    let data: [ProductModel]
}
