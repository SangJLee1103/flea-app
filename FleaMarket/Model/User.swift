//
//  User.swift
//  FleaMarket
//
//  Created by 이상준 on 2022/04/15.
//

import Foundation

// 회원 구조체
struct User {
    
    var email: String? //회원 이메일
    var password: String? // 회원 비밀번호
    var nickname: String? // 회원 닉네임
    var phoneNumber: String? // 회원 휴대폰 번호
    
    //구조체는 init()을 자동으로 갖음
}
