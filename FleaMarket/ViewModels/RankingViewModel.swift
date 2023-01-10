//
//  RankingViewModel.swift
//  FleaMarket
//
//  Created by 이상준 on 2023/01/10.
//

import UIKit

struct RankingViewModel {
    var ranker: ProductRankingModel

    var id: Int { return ranker.id }
    var img: URL? { return URL(string: "\(Network.url)/\(ranker.productImg.split(separator:",")[0])") }
    var productName: String { return ranker.productName }
    var sellerName: String { return ranker.sellerName }
    var price: String { return NumberFormat.formatPrice(price: ranker.price) }
    var likesCount: Int { return ranker.likesCount }
    
    
    init(ranker: ProductRankingModel) {
        self.ranker = ranker
    }
}
