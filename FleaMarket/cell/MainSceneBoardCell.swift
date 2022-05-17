//
//  MainSceneBoardCell.swift
//  FleaMarket
//
//  Created by 이상준 on 2022/04/27.
//

import Foundation
import UIKit


class MainSceneBoardCell: UICollectionViewCell{
    
    
    @IBOutlet var image: UIImageView!
    @IBOutlet var writer: UILabel!
    @IBOutlet var date: UILabel!
    @IBOutlet var topic: UILabel!
    
    public func configureCell(with model: NSDictionary) {
    }
}

