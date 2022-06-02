//
//  JoinError.swift
//  FleaMarket
//
//  Created by 이상준 on 2022/06/02.
//

import Foundation

struct JoinResponse {
    var status: Int? // 상태코드
    var message: String? // 응답 메시지
    var error: Array<NSDictionary> // 응답 에러 객체
}
