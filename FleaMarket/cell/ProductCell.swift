//
//  ProductCell.swift
//  FleaMarket
//
//  Created by 이상준 on 2022/05/17.
//

import UIKit

class ProductCell: UICollectionViewCell {
    
    @IBOutlet var img: UIImageView!
    @IBOutlet var likeBtn: UIButton!
    @IBOutlet var sellerName: UILabel!
    @IBOutlet var name: UILabel!
    @IBOutlet var sellingPrice: UILabel!
    
    
    @IBAction func likeCount(_ sender: UIButton) {
        if likeBtn.tag == 0 {
            likeBtn.configuration?.image = UIImage(systemName: "heart.fill")
            print("suit.heart.fill")
            likeBtn.tag = 1
        }else {
            likeBtn.configuration?.image = UIImage(systemName: "heart")
            print("suit.heart")
            likeBtn.tag = 0
        }
    }
}
