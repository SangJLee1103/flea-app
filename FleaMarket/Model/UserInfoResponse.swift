//
//  UserInfoResponse.swift
//  FleaMarket
//
//  Created by 이상준 on 2022/06/13.
//

import Foundation

class UserInfoResponse {
    var email: String?
    var password: String?
    var nickname: String?
    var phoneNumber: String?
    var boards: NSArray? // 자신이 작성한 플리마켓 리스트
    var products: NSArray? // 자신이 올린 상품 리스트
    var likes: NSArray? // 자신이 좋아효 한 상품 리스트
}
