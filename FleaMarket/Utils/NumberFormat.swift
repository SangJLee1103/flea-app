//
//  NumberFormatter.swift
//  FleaMarket
//
//  Created by 이상준 on 2023/01/10.
//

import Foundation

struct NumberFormat {
    
    static func formatPrice(price: Int) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value: price)) ?? ""
    }
}
