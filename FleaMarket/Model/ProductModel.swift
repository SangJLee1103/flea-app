//
//  Product.swift
//  FleaMarket
//
//  Created by 이상준 on 2022/06/04.
//
import Foundation
import UIKit

class ProductModel {
    var id: Int?
    var imgPath: String? // 이미지 경로
    var productName: String? // 상품명
    var sellerName: String? // 판매자 메일
    var sellingPrice: Int? // 판매 가격
    var createdAt: String? // 생성날짜
    var costPrice: Int? // 시가
    var boardId: Int? // 게시글 아이디
    var description: String? // 상품 상세 설명
    var like: NSArray? // 좋아요
    var thumbnailImage: UIImage? // 이미지
}
