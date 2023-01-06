//
//  SelectedImageCell.swift
//  FleaMarket
//
//  Created by 이상준 on 2022/05/23.
//
import UIKit

// MARK: - 이미지 삭제에 대한 델리게이트
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
