//
//  SelectedImageCell.swift
//  FleaMarket
//
//  Created by 이상준 on 2022/05/23.
//

import Foundation
import UIKit


protocol DataCollectionProtocol {
    func deleteData(index: Int)
}

class SelectedImageCell: UICollectionViewCell {
    
    @IBOutlet var selectedImg: UIImageView!
    @IBOutlet var cancelImgBtn: UIButton!
    
    var delegate: DataCollectionProtocol?
    var index: IndexPath?
    
    @IBAction func cancelImg(_ sender: UIButton) {
        delegate?.deleteData(index: (index?.row)!)
    }
}
