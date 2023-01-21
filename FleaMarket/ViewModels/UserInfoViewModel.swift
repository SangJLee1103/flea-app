//
//  UserInfoViewModel.swift
//  FleaMarket
//
//  Created by 이상준 on 2023/01/21.
//

import Foundation

struct UserInfoViewModel {
    var userInfo: UserInfoModel
    
    var id: String {
        return userInfo.id
    }
    
    var nickname: String {
        return userInfo.nickname
    }
    
    var phone: String {
        return userInfo.phone
    }
    
    var password: String {
        return userInfo.password
    }
    
    var boards: [BoardModel] {
        return userInfo.boards ?? []
    }
    
    var products: [ProductModel] {
        return userInfo.products ?? []
    }
    
    var likes: [LikesModel] {
        return userInfo.likes ?? []
    }
    
    
    init(userInfo: UserInfoModel) {
        self.userInfo = userInfo
    }
    
}
