//
//  TopLankingProductCell.swift
//  FleaMarket
//
//  Created by 이상준 on 2022/05/08.
//

import SDWebImage
import UIKit

class TopRankingCell: UICollectionViewCell {
    
    var viewModel: RankingViewModel? {
        didSet { configure() }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        productImg.layer.cornerRadius = 10
    }
    
    @IBOutlet var rankingLbl: UILabel!
    @IBOutlet var productImg: UIImageView!
    @IBOutlet var sellerName: UILabel!
    @IBOutlet var productName: UILabel!
    @IBOutlet var sellingPrice: UILabel!
    
    func configure() {
        guard let viewModel = viewModel else { return }
        
        productImg.sd_setImage(with: viewModel.img)
        sellerName.text = viewModel.sellerName
        productName.text = viewModel.productName
        sellingPrice.text = "\(viewModel.price)"
    }
}
