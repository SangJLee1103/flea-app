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

class ProductModifyViewController: UIViewController {
    
    @IBOutlet var productImgView: UICollectionView!
    @IBOutlet var productName: UITextField!
    @IBOutlet var sellingPrice: UITextField!
    @IBOutlet var costPrice: UITextField!
    @IBOutlet var descriptionField: UITextView!
    
    let token = Keychain.read(key: "accessToken")
    
    let placeholder = "상품에 대해서 설명을 적어주세요(상품 사용 기간, 상품의 흠집 여부 및 특징 등)"
    
//    var productInfo = ProductModel()
    
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
        
//        configureProductUI()
    }
    
    
    // MARK: - 선택 이미지 셀에 이미지를 넣어주는 함수
//    func imgIntoUserSelectedImg() {
//        let imgPath = self.productInfo.imgPath
//        let imgParse = imgPath!.split(separator:",")
//
//        for i in 0..<imgParse.count {
//            let url: URL! = URL(string: "\(Network.url)/\(imgParse[i])")
//            let imageData = try! Data(contentsOf: url)
//            self.userSelectedImages.append(UIImage(data: imageData)!)
//            self.selectedData.append(imageData)
//            self.selectedCount = imgParse.count
//        }
//    }
    
    // MARK: - 현재 상품 UI 구성
//    func configureProductUI() {
//        self.imgIntoUserSelectedImg()
//        self.productName.text = self.productInfo.productName
//        self.sellingPrice.text = "\(String(describing: self.productInfo.sellingPrice!))"
//        self.costPrice.text = "\(String(describing: self.productInfo.costPrice!))"
//        self.descriptionField.text = self.productInfo.description
//    }
    
    
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
        
        print("날짜 포멧 함수\(dateFormatter.string(from: createdAt))")
        
        let formatDate = dateFormatter.string(from: createdAt)
        return formatDate
    }
    
    // 완료 버튼 클릭시 이벤트(상품 등록)
    @objc func productRegist(){
//        guard let productId = self.productInfo.id else { return }
//        guard let url = URL(string: "\(Network.url)/product/\(productId)") else {
//            print("Error: cannot create URL")
//            return
//        }
//        
//        let name = self.productName?.text
//        let cost_price = self.costPrice?.text
//        let selling_price = self.sellingPrice?.text
//        let description = self.descriptionField?.text
//        let createdAt = dateToString(Date())
//        
//        let parameters = [
//            "name" : name!,
//            "selling_price" : selling_price!,
//            "cost_price" : cost_price!,
//            "description" : description!,
//            "created_at" : createdAt
//        ] as [String : Any]
//        
//        // boundary 설정
//        let boundary = "Boundary-\(UUID().uuidString)"
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "PUT"
//        request.setValue("Bearer \(token!)", forHTTPHeaderField: "Authorization")
//        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
//        
//        // data
//        var uploadData = Data()
//        let imgDataKey = "img"
//        let boundaryPrefix = "--\(boundary)\r\n"
//        
//        for (key, value) in parameters {
//            uploadData.append(boundaryPrefix.data(using: .utf8)!)
//            uploadData.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
//            uploadData.append("\(value)\r\n".data(using: .utf8)!)
//        }
//        
//        
//        for data in selectedData {
//            uploadData.append(boundaryPrefix.data(using: .utf8)!)
//            uploadData.append("Content-Disposition: form-data; name=\"\(imgDataKey)\"; filename=\"\("Img").png\"\r\n".data(using: .utf8)!)
//            uploadData.append("Content-Type: \("image/png")\r\n\r\n".data(using: .utf8)!)
//            uploadData.append(data)
//            uploadData.append("\r\n".data(using: .utf8)!)
//        }
//        uploadData.append("--\(boundary)--".data(using: .utf8)!)
//        
//        
//        URLSession.shared.uploadTask(with: request, from: uploadData) { (data: Data?, response: URLResponse?, error: Error?) in
//            DispatchQueue.main.async() {
//                do {
//                    let object = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary
//                    
//                    guard let jsonObject = object else { return }
//                    
//                    let status = (response as? HTTPURLResponse)?.statusCode ?? 0
//                    let data = jsonObject["message"] as? String
//                    let errorArray = jsonObject["message"] as? Array<NSDictionary>
//                    let error = errorArray?[0]["msg"] as? String
//                    
//                    if (status == 201) {
//                        let alert = UIAlertController(title: "Flea Market", message: data, preferredStyle: .alert)
//                        let action = UIAlertAction(title: "확인", style: .cancel){ (_) in
//                            self.navigationController?.popToRootViewController(animated: true)
//                        }
//                        alert.addAction(action)
//                        self.present(alert, animated: true, completion: nil)
//                    }else {
//                        let checkAlert = UIAlertController(title: "Flea Market", message: error, preferredStyle: .alert)
//                        
//                        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
//                        checkAlert.addAction(action)
//                        self.present(checkAlert, animated: true, completion: nil)
//                    }
//                }catch let e as NSError {
//                    print("An error has occured while parsing JSONObject: \(e.localizedDescription)")
//                }
//            }
//        }.resume()
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

