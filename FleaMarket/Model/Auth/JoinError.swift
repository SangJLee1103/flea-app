//
//  JoinResponse.swift
//  FleaMarket
//
//  Created by 이상준 on 2023/01/03.
//

import Foundation

struct JoinError: Decodable {
    let msg: String
    let param: String?
}

struct JoinErrArr: Decodable {
    var message: [JoinError]
}

