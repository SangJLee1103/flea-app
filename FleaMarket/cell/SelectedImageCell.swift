//
//  SelectedImageCell.swift
//  FleaMarket
//
//  Created by 이상준 on 2022/05/23.
//

import Foundation
import UIKit

class SelectedImageCell: UICollectionViewCell {
    
    @IBOutlet var selectedImg: UIImageView!
    @IBOutlet var cancelImgBtn: UIButton!
    
    var index = [0, 1, 2, 3, 4]
    
    @IBAction func cancelImageBtn(_ sender: UIButton) {
        
    }
}
