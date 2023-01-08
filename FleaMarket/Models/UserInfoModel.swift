//
//  UserInfoResponse.swift
//  FleaMarket
//
//  Created by 이상준 on 2022/06/13.
//

import Foundation

struct UserInfoModel: Decodable {
    let email: String?
    let password: String?
    let nickname: String?
    let phoneNumber: String?
    let boards: [BoardModel] // 자신이 작성한 플리마켓 리스트
    let products: [ProductModel] // 자신이 올린 상품 리스트
    let likes: [LikesModel]// 자신이 좋아효 한 상품 리스트
}
