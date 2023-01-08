//
//  Board.swift
//  FleaMarket
//
//  Created by 이상준 on 2022/06/02.
//

import Foundation

struct BoardModel: Codable {
    let id: Int // 게시글 아이디
    let user: String // 게시글 작성자
    let topic: String
    let start: String // 플리마켓 날짜
    let place: String // 플리마켓 장소
    let description: String // 플리마켓 주제
    let thumbnail: String // 이미지 경로
    
    enum CodingKeys: String, CodingKey {
        case id, topic, start, place, description, thumbnail
        case user = "User"
    }
}

struct BoardArray: Decodable {
    let data: [BoardModel]
}


