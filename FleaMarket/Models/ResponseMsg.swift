//
//  JoinResponse.swift
//  FleaMarket
//
//  Created by 이상준 on 2023/01/03.
//

import Foundation

// 회원가입 response 모델
struct ResponseMsg: Decodable {
    let msg: String
    let param: String?
}

struct ResponseMsgArr: Decodable {
    var message: [ResponseMsg]
}

