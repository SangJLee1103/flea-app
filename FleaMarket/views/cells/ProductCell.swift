//
//  ProductCell.swift
//  FleaMarket
//
//  Created by 이상준 on 2022/05/17.
//

import UIKit

class ProductCell: UICollectionViewCell {
    
    var viewModel: ProductViewModel? {
        didSet { configure() }
    }
    
    var productId: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        img.layer.cornerRadius = 10
    }
    
    @IBOutlet var img: UIImageView!
    @IBOutlet var likeBtn: UIButton!
    @IBOutlet var sellerName: UILabel!
    @IBOutlet var name: UILabel!
    @IBOutlet var sellingPrice: UILabel!
    
    func configure() {
        guard let viewModel = viewModel else { return }
        productId = viewModel.product.id
        img.sd_setImage(with: viewModel.img)
        sellerName.text = viewModel.nickname
        name.text = viewModel.name
        sellingPrice.text = viewModel.sellingPrice
    }
    
    
    // 상품 좋아요 UI 적용
    func likeUI() {
        if(likeBtn.tag == 1){
            DispatchQueue.main.async {
                self.likeBtn.configuration?.image = UIImage(systemName: "heart.fill")
            }
        }else {
            DispatchQueue.main.async {
                self.likeBtn.configuration?.image = UIImage(systemName: "heart")
            }
        }
    }
    
    @IBAction func likeCount(_ sender: UIButton) {
        if likeBtn.tag == 0 {
            likeBtn.configuration?.image = UIImage(systemName: "heart.fill")
            likeBtn.tag = 1
            ProductService.likeProduct(productId: productId)
        }else {
            likeBtn.configuration?.image = UIImage(systemName: "heart")
            likeBtn.tag = 0
            ProductService.unlikeProduct(productId: productId)
        }
    }
}
