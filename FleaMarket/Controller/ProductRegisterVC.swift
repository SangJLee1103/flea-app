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
    var selectedCount = 0
    
    
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
        
        if selectedCount == 5 {
            let alert = UIAlertController(title: "FleaMarket", message: "사진은 5개까지 등록 가능합니다", preferredStyle: .alert)
            
            let action = UIAlertAction(title: "확인", style: .cancel, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: false)
        }
        
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
            self.selectedCount += 1
        }
            print("올라간 사진: ", self.selectedCount)
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
                
                self.productImgView.reloadData()
            }
        }
}



extension ProductRegisterVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        selectedData.count
    }
    
    // 컬렉션 뷰 셀에 대한 설정
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cellId = String(describing: "SelectedImageCell")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! SelectedImageCell
        
        cell.cancelImgBtn.tag = indexPath.row
        cell.cancelImgBtn.addTarget(self, action: #selector(cancelImg(sender: )), for: .touchUpInside)
        cell.selectedImg.image = self.userSelectedImages[indexPath.row]
        
        return cell
    }
    
    //선택된 이미지취소(x) 버튼 클릭시 이벤트
    @objc func cancelImg(sender: UIButton){
        let alert = UIAlertController(title: "FleaMarket", message: "이미지를 삭제하시겠습니까?", preferredStyle: .alert)

        let confirm = UIAlertAction(title: "확인", style: .default, handler: { (_) in
            self.productImgView.performBatchUpdates({
                self.productImgView.deleteItems(at: [IndexPath.init(row: sender.tag, section: 0)])
                self.selectedData.remove(at: sender.tag)
                print(sender.tag, "번째 사진 삭제")
                self.selectedCount -= 1
            }, completion: { (_) in
                self.productImgView.reloadData()
            }
            )}
        )
        

        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)

        alert.addAction(confirm)
        alert.addAction(cancel)

        self.present(alert, animated: false)
    }
}

// 액션 관련
extension ProductRegisterVC: UICollectionViewDelegate {
    
}
