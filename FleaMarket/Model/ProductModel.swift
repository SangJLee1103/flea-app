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
    var productName: String?
    var sellerName: String?
    var sellingPrice: Int?
    var createdAt: String?
    var costPrice: Int?
    var description: String?
    var like: NSArray?
    var thumbnailImage: UIImage? // 이미지
}
