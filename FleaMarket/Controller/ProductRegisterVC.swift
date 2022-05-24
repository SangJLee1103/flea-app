//
//  productDetailVC.swift
//  FleaMarket
//
//  Created by 이상준 on 2022/05/19.
//

import UIKit
import Photos
import BSImagePicker

class ProductRegisterVC: UIViewController, UITextViewDelegate {
    
    let placeholder = "상품에 대해서 설명을 적어주세요(상품 사용 기간, 상품의 흠집 여부 및 특징 등)"
    
    
    
    @IBOutlet var productImgView: UICollectionView!
    @IBOutlet var productName: UITextField!
    @IBOutlet var sellingPrice: UITextField!
    @IBOutlet var costPrice: UITextField!
    @IBOutlet var descriptionField: UITextView!
    
    
    var selectedData:[Data]! = [Data]()
    var selectedAssets = [PHAsset]()
    var userSelectedImages = [UIImage]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        descriptionField.delegate = self
        descriptionField.text = placeholder
        descriptionField.textColor = .lightGray
        
        productImgView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        productImgView.dataSource = self
        productImgView.delegate = self
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if descriptionField.textColor == .lightGray {
            descriptionField.text = ""
            descriptionField.textColor = .black
        }
    }
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if descriptionField.text == "" {
            descriptionField.text = placeholder
            descriptionField.textColor = .lightGray
        }
    }
    
    // 이미지 선택
    @IBAction func openGalary(_ sender: UIButton) {
        // 이미지 피커 컨트롤러 인스턴스 생성
        let picker = ImagePickerController()
        picker.settings.selection.max = 5
        picker.settings.fetch.assets.supportedMediaTypes = [.image]
                
        presentImagePicker(picker, select: { (asset) in
            // User selected an asset. Do something with it. Perhaps begin processing/upload?
        }, deselect: { (asset) in
            // User deselected an asset. Cancel whatever you did when asset was selected.
        }, cancel: { (assets) in
            // User canceled selection.
        }, finish: { (assets) in
            // User finished selection assets.
        for i in 0..<assets.count {
            self.selectedAssets.append(assets[i])
        }
            self.convertAssetToImages()
        })
    }
    
    func convertAssetToImages() {
            if selectedAssets.count != 0 {
//                self.selectedData.removeAll()
//                self.userSelectedImages.removeAll()
                
                for i in 0..<selectedAssets.count {
                    
                    let imageManager = PHImageManager.default()
                    let option = PHImageRequestOptions()
                    var thumbnail = UIImage()
                    option.isSynchronous = true
                    imageManager.requestImage(for: selectedAssets[i],
                                              targetSize: CGSize(width: 30, height: 30),
                                                 contentMode: .aspectFill,
                                              options: option) { (result, info) in
                    thumbnail = result!
                    }
                    
                    let data = thumbnail.jpegData(compressionQuality: 0.7)
                    let newImage = UIImage(data: data!)

                    
                    self.userSelectedImages.append(newImage! as UIImage)
                    self.selectedData.append(data!)
                }
                
                DispatchQueue.main.async {
                    self.productImgView.reloadData()
                }
            }
        }
}



extension ProductRegisterVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedData.count
    }
    
    // 컬렉션 뷰 셀에 대한 설정
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cellId = String(describing: "SelectedImageCell")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! SelectedImageCell
        
        cell.selectedImg.image = self.userSelectedImages[indexPath.row]
        
        return cell
    }
}

// 액션 관련
extension ProductRegisterVC: UICollectionViewDelegate {
    
}
