//
//  UserInfoResponse.swift
//  FleaMarket
//
//  Created by 이상준 on 2022/06/13.
//

import Foundation

struct UserInfoModel: Decodable {
    let id: String
    let password: String
    let nickname: String
    let phone: String
    let boards: [BoardModel]? // 자신이 작성한 플리마켓 리스트
    let products: [ProductModel]?
    let likes: [LikesModel]?// 자신이 좋아효 한 상품 리스트
    
    enum CodingKeys: String, CodingKey {
        case id, password, nickname, phone
        case boards = "Boards"
        case products = "Products"
        case likes = "Likes"
    }
}

struct List: Decodable {
    let list: UserInfoModel
}

