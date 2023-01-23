//
//  Board.swift
//  FleaMarket
//
//  Created by 이상준 on 2022/06/02.
//

import Foundation

struct BoardModel: Decodable {
    let id: Int // 게시글 아이디
    let user: User? // 게시글 작성자
    let topic: String
    let start: String // 플리마켓 날짜
    let place: String // 플리마켓 장소
    let description: String // 플리마켓 주제
    let thumbnail: String // 이미지 경로
    let userId: String
    
    enum CodingKeys: String, CodingKey {
        case id, topic, start, place, description, thumbnail
        case user = "User"
        case userId = "user_id"
    }
}

struct BoardArray: Decodable {
    let data: [BoardModel]
}

struct User: Decodable {
    let nickname : String
}


