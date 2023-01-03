//
//  LoginError.swift
//  FleaMarket
//
//  Created by 이상준 on 2023/01/03.
//

import Foundation

struct LoginResponse: Decodable {
    let message: String?
    let accessToken: String?
}
