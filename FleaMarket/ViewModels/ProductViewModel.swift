//
//  ProductViewModel.swift
//  FleaMarket
//
//  Created by 이상준 on 2023/01/07.
//

import UIKit

struct ProductViewModel {
    var product: ProductModel
    
    var boardId: Int { return product.boardId }
    var name: String { return product.name }
    var costPrice: String { return NumberFormat.formatPrice(price: product.costPrice) }
    var sellingPrice: String { return NumberFormat.formatPrice(price: product.sellingPrice) }
    var description: String { return "\(product.description)" }
    var boardTitle: String { return product.boardTitle}
    var img: URL? { return URL(string: "\(Network.url)/\(product.img.split(separator:",")[0])") }
    var imgArray: [String]? { return product.img.components(separatedBy: ",") } 
    var createdAt: String { return product.createdAt }
    var nickname: String { return product.user?.nickname ?? "" }
    var likesCnt: Int { return product.likes.count }
    var start: String? { return product.board?.start }
    
    init(product: ProductModel) {
        self.product = product
    }
}
