//
//  MainSceneBoardCell.swift
//  FleaMarket
//
//  Created by 이상준 on 2022/04/27.
//

import Foundation
import SDWebImage
import UIKit


class MainBoardCell: UICollectionViewCell{
    
    var viewModel: BoardViewModel? {
        didSet { configure() }
    }
    
    @IBOutlet var image: UIImageView!
    @IBOutlet var topic: UILabel!
    @IBOutlet var date: UILabel!
    @IBOutlet var place: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        image.layer.cornerRadius = 10
    }
    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
    
    func configure() {
        guard let viewModel = viewModel else { return }
        image.sd_setImage(with: viewModel.imageUrl)
        topic.text = viewModel.topic
        date.text = viewModel.date
        place.text = viewModel.place
    }
}

