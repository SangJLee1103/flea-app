//
//  BoardCell.swift
//  FleaMarket
//
//  Created by 이상준 on 2022/08/06.
//

import Foundation
import UIKit

class BoardCell: UITableViewCell {
    
    var viewModel: BoardViewModel? {
        didSet { configure() }
    }
    
    @IBOutlet var img: UIImageView!
    @IBOutlet var topic: UILabel!
    @IBOutlet var date: UILabel!
    @IBOutlet var place: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        img.layer.cornerRadius = 10
    }
    
    func configure() {
        guard let viewModel = viewModel else { return }
        img.sd_setImage(with: viewModel.imageUrl)
        topic.text = viewModel.topic
        date.text = viewModel.date
        place.text = viewModel.place
    }
    
}
