//
//  MyUploadItemCell.swift
//  FleaMarket
//
//  Created by 이상준 on 2022/06/13.
//

import Foundation
import UIKit
import SDWebImage

class ItemCell: UITableViewCell {
    
    var viewModel: ProductViewModel? {
        didSet {
            configure()
        }
    }
    
    @IBOutlet var productImg: UIImageView!
    @IBOutlet var productName: UILabel!
    @IBOutlet var createdAt: UILabel!
    @IBOutlet var price: UILabel!
    @IBOutlet var likeCount: UILabel!
    
        
    func configure() {
        guard let viewModel = viewModel else { return }
        productImg.sd_setImage(with: viewModel.img)
        productName.text = viewModel.name
        createdAt.text = viewModel.createdAt
        price.text = viewModel.sellingPrice
        likeCount.text = "\(viewModel.likesCnt)"
    }
    
}
