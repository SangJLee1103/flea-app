//
//  productDetailVC.swift
//  FleaMarket
//
//  Created by 이상준 on 2022/05/19.
//

import UIKit
import Photos
import BSImagePicker

class ProductRegistrationViewController: UIViewController, UICollectionViewDelegate {
    
    @IBOutlet var productImgView: UICollectionView!
    @IBOutlet var productName: UITextField!
    @IBOutlet var sellingPrice: UITextField!
    @IBOutlet var costPrice: UITextField!
    @IBOutlet var descriptionField: UITextView!
    
    
    let placeholder = "상품에 대해서 설명을 적어주세요(상품 사용 기간, 상품의 흠집 여부 및 특징 등)"
    var boardId: Int?
    
    // 상품 업로드 날짜
    var selectedData: [Data] = [Data]()
    var selectedAssets = [PHAsset]()
    var userSelectedImages = [UIImage]()
    var selectedCount = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "상품 등록하기"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(productRegist))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.systemYellow
        
        productName.delegate = self
        sellingPrice.delegate = self
        costPrice.delegate = self
        
        descriptionField.delegate = self
        descriptionField.text = placeholder
        descriptionField.textColor = .lightGray
        
        productImgView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        productImgView.dataSource = self
        productImgView.delegate = self
    }
    
    // MARK: - 완료 버튼 클릭시 이벤트(상품 등록)
    @objc func productRegist(){
        guard let name = self.productName.text else { return }
        guard let costPrice = self.costPrice.text else { return }
        guard let sellingPrice = self.sellingPrice.text else { return }
        var description = self.descriptionField.text
        let createdAt = dateToString(Date())
        guard let boardId = boardId else { return }
        
        if description == placeholder {
            description = ""
        }
        
        ProductService.postProduct(name: name, sellingPrice: sellingPrice, costPrice: costPrice, description: description ?? "", boardId: boardId, createdAt: createdAt, selectedData: selectedData) { [weak self] response in
            switch response {
            case.success((let result, let status)):
                if status == 201 {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Flea Market", message: result.message[0].msg, preferredStyle: .alert)
                        let action = UIAlertAction(title: "확인", style: .cancel){ (_) in
                            self?.navigationController?.popToRootViewController(animated: true)
                        }
                        alert.addAction(action)
                        self?.present(alert, animated: true, completion: nil)
                    }
                } else {
                    DispatchQueue.main.async {
                        let checkAlert = UIAlertController(title: "Flea Market", message: result.message[0].msg, preferredStyle: .alert)
                        
                        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                        checkAlert.addAction(action)
                        self?.present(checkAlert, animated: true, completion: nil)
                    }
                }
            case.failure(_):
                print("Error")
            }
        }
    }
    
    // MARK: - 날짜 포맷함수
    func dateToString(_ createdAt: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm" // formatter의 dateFormat 속성을 설정
        dateFormatter.locale = Locale(identifier:"ko_KR")
        
        let formatDate = dateFormatter.string(from: createdAt)
        return formatDate
    }
    
    // MARK: - asset 타입을 image 타입으로 변환
    func convertAssetToImages() {
        if selectedAssets.count != 0 {
            for i in 0..<selectedAssets.count {
                
                let imageManager = PHImageManager.default()
                let option = PHImageRequestOptions()
                var thumbnail = UIImage()
                option.isSynchronous = true
                imageManager.requestImage(for: selectedAssets[i],
                                          targetSize: CGSize(width: 400, height: 400),
                                          contentMode: .aspectFill,
                                          options: option) { (result, info) in
                    thumbnail = result!
                }
                
                guard let data = thumbnail.jpegData(compressionQuality: 1.0) else { return }
                let newImage = UIImage(data: data)
                
                self.userSelectedImages.append(newImage! as UIImage)
                self.selectedData.append(data)
            }
            self.productImgView.reloadData()
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
        
        picker.settings.selection.max = 5 - selectedCount
        picker.settings.fetch.assets.supportedMediaTypes = [.image]
        
        presentImagePicker(picker, select: { (asset) in
        }, deselect: { (asset) in
        }, cancel: { (assets) in
        }, finish: { (assets) in
            
            for i in 0..<assets.count {
                self.selectedAssets.append(assets[i])
                self.selectedCount += 1
            }
            self.convertAssetToImages() // image 타입으로 변환하는 함수 실행
            self.selectedAssets.removeAll() // Assets 배열을 비워준다.
        })
    }
}

extension ProductRegistrationViewController: UITextFieldDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // TextField 비활성화
        return true
    }
}

// MARK: - 텍스트 뷰 관리
extension ProductRegistrationViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if descriptionField.text == placeholder {
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
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
        } else {
        }
        return true
    }
}


// MARK: - 컬렉션 뷰 데이터소스 관리
extension ProductRegistrationViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedData.count
    }
    
    // 컬렉션 뷰 셀에 대한 설정
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cellId = String(describing: "SelectedImageCell")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! SelectedImageCell
        cell.selectedImg.image = self.userSelectedImages[indexPath.row]
        cell.index = indexPath
        cell.delegate = self
        
        return cell
    }
}

// MARK: - 등록할 이미지 셀에 대한 프로토콜
extension ProductRegistrationViewController: DataCollectionProtocol {
    func deleteData(index: Int) {
        self.selectedCount = self.selectedCount - 1
        self.selectedData.remove(at: index)
        self.userSelectedImages.remove(at: index)
        self.productImgView.reloadData()
    }
}
