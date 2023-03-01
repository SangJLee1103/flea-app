//
//  ItemModifyViewController.swift
//  FleaMarket
//
//  Created by 이상준 on 2022/08/08.
//

import Foundation
import UIKit
import Photos
import BSImagePicker
import SDWebImage

class ProductModifyViewController: UIViewController {
    
    @IBOutlet var productImgView: UICollectionView!
    @IBOutlet var productName: UITextField!
    @IBOutlet var sellingPrice: UITextField!
    @IBOutlet var costPrice: UITextField!
    @IBOutlet var descriptionField: UITextView!
    
    let token = Keychain.read(key: "accessToken")
    
    let placeholder = "상품에 대해서 설명을 적어주세요(상품 사용 기간, 상품의 흠집 여부 및 특징 등)"
    
    var product: ProductModel?
    
    var selectedData: [Data] = [Data]()
    var selectedAssets = [PHAsset]()
    var userSelectedImages = [UIImage]()
    var selectedCount = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "상품정보 수정"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(productRegist))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.systemYellow
        
        descriptionField.delegate = self
        descriptionField.text = placeholder
        descriptionField.textColor = .black
        
        productImgView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        productImgView.dataSource = self
        productImgView.delegate = self
        
        imgIntoUserSelectedImg()
        configure()
    }
    
    
    // MARK: - 선택 이미지 셀에 이미지를 넣어주는 함수
    func imgIntoUserSelectedImg() {
        guard let product = product else { return }
        let imgPath = product.img
        let imgParse = imgPath.split(separator:",")
        
        for i in 0..<imgParse.count {
            guard let url = URL(string: "\(Network.url)/\(imgParse[i])") else { return }
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                guard let imageData = data else { return }
                self.userSelectedImages.append(UIImage(data: imageData)!)
                self.selectedData.append(imageData)
                self.selectedCount = imgParse.count
            }.resume()
        }
        
    }
    
    //MARK: - 현재 상품 UI 구성
    func configure() {
        guard let product = product else { return }
        self.productName.text = product.name
        self.sellingPrice.text = "\(String(describing: product.sellingPrice))"
        self.costPrice.text = "\(String(describing: product.costPrice))"
        self.descriptionField.text = product.description
    }
    
    
    // asset 타입을 image 타입으로 변환
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
                
                let data = thumbnail.jpegData(compressionQuality: 1.0)
                let newImage = UIImage(data: data!)
                
                self.userSelectedImages.append(newImage! as UIImage)
                self.selectedData.append(data!)
            }
            self.productImgView.reloadData()
        }
    }
    
    func dateToString(_ createdAt: Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm" // formatter의 dateFormat 속성을 설정
        dateFormatter.locale = Locale(identifier:"ko_KR")
        
        let formatDate = dateFormatter.string(from: createdAt)
        return formatDate
    }
    
    // 완료 버튼 클릭시 이벤트(상품 등록)
    @objc func productRegist(){
        guard let product = product else { return }
        guard let name = self.productName.text else { return }
        guard let costPrice = self.costPrice.text else { return }
        guard let sellingPrice = self.sellingPrice.text else { return }
        var description = self.descriptionField.text
        let createdAt = dateToString(Date())
        
        ProductService.updateProduct(productId: product.id, name: name, sellingPrice: sellingPrice, costPrice: costPrice, description: description ?? "", createdAt: createdAt, selectedData: selectedData) { [weak self] response in
            switch response {
            case .success((let result, let status)):
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
            case .failure(_):
                print("Error")
            }
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

// MARK: - 텍스트 뷰 관리
extension ProductModifyViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if descriptionField.textColor == #colorLiteral(red: 0.8209919333, green: 0.8216187358, blue: 0.8407624364, alpha: 1) {
            descriptionField.text = ""
            descriptionField.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if descriptionField.text == "" {
            descriptionField.text = placeholder
            descriptionField.textColor = #colorLiteral(red: 0.8209919333, green: 0.8216187358, blue: 0.8407624364, alpha: 1)
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

extension ProductModifyViewController: UITextFieldDelegate {
    
    //화면 터치시 키보드 내림
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // TextField 비활성화
        return true
    }
}

// MARK: - 컬렉션 뷰 데이터소스 관리
extension ProductModifyViewController: UICollectionViewDataSource, UICollectionViewDelegate {
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
extension ProductModifyViewController: DataCollectionProtocol {
    func deleteData(index: Int) {
        self.selectedCount = self.selectedCount - 1
        self.selectedData.remove(at: index)
        self.userSelectedImages.remove(at: index)
        self.productImgView.reloadData()
    }
}

