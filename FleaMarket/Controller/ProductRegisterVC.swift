//
//  productDetailVC.swift
//  FleaMarket
//
//  Created by 이상준 on 2022/05/19.
//

import UIKit
import Photos
import BSImagePicker

class ProductRegisterVC: UIViewController, UITextViewDelegate, UICollectionViewDelegate {
    
    let placeholder = "상품에 대해서 설명을 적어주세요(상품 사용 기간, 상품의 흠집 여부 및 특징 등)"
    
    var boardId: Int?
    
    @IBOutlet var productImgView: UICollectionView!
    @IBOutlet var productName: UITextField!
    @IBOutlet var sellingPrice: UITextField!
    @IBOutlet var costPrice: UITextField!
    @IBOutlet var descriptionField: UITextView!
    
    let token = Keychain.read(key: "accessToken")
    
    var selectedData: [Data] = [Data]()
    var selectedAssets = [PHAsset]()
    var userSelectedImages = [UIImage]()
    var selectedCount = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "상품 등록하기"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(productRegist))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.systemYellow
        
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
    
    
    // POST - Image 송신
    // ✅ data : UIImage 를 pngData() 혹은 jpegData() 사용해서 Data 로 변환한 것.
    // ✅ filename : 파일이름(img.jpg 과 같은 이름)
    // ✅ mimeType :  타입에 맞게 png면 image/png, text text/plain 등 타입.
    // 완료 버튼 클릭시 이벤트
    @objc func productRegist(){
        
        guard let url = URL(string: "http://localhost:3000/product/\(boardId!)/register") else {
            print("Error: cannot create URL")
            return
        }
        
        let name = self.productName?.text
        let cost_price = Int((self.costPrice?.text)!)
        let selling_price = Int((self.sellingPrice?.text)!)
        let description = self.descriptionField?.text
        
        
        let parameters = [
            "name" : name!,
            "cost_price" : cost_price!,
            "selling_price" : selling_price!,
            "description" : description!
        ] as [String : Any]


        
        
        // ✅ boundary 설정
        let boundary = "Boundary-\(UUID().uuidString)"
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token!)", forHTTPHeaderField: "Authorization")
    
        // ✅ data
        var uploadData = Data()
        let imgDataKey = "img"
        let boundaryPrefix = "--\(boundary)\r\n"
        
        for (key, value) in parameters {
            uploadData.append(boundaryPrefix.data(using: .utf8)!)
            uploadData.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            uploadData.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        
        for data in selectedData {
            uploadData.append(boundaryPrefix.data(using: .utf8)!)
            uploadData.append("Content-Disposition: form-data; name=\"\(imgDataKey)\"; filename=\"\("Img").png\"\r\n".data(using: .utf8)!)
            uploadData.append("Content-Type: \("image/png")\r\n\r\n".data(using: .utf8)!)
            uploadData.append(data)
            uploadData.append("\r\n".data(using: .utf8)!)
        }
        uploadData.append("--\(boundary)--".data(using: .utf8)!)
    
        let defaultSession = URLSession(configuration: .default)
        // ✅ uploadTask(with:from:) 메서드 사용해서 reqeust body 에 data 추가.
        defaultSession.uploadTask(with: request, from: uploadData) { (data: Data?, response: URLResponse?, error: Error?) in
            DispatchQueue.main.async() {
                do {
                    let object = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary
                    guard let jsonObject = object else { return }
                    //response 데이터 획득, utf8인코딩을 통해 string형태로 변환
                    let status = (response as? HTTPURLResponse)?.statusCode ?? 0
                    let data = jsonObject["message"] as? String
                    
                    if (status == 201) {
                        let alert = UIAlertController(title: "Flea Market", message: data, preferredStyle: .alert)
                        let action = UIAlertAction(title: "확인", style: .cancel){ (_) in
                            self.navigationController?.popToRootViewController(animated: true)
                        }
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil)
                    }else {
                        print("실패")
                    }
                }catch let e as NSError {
                    print("An error has occured while parsing JSONObject: \(e.localizedDescription)")
                }
            }
        }.resume()
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
            self.convertAssetToImages() // image 타입으로 변환하는 함수 실행
        })
    }
    
    // asset 타입을 image 타입으로 변환
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
                                             targetSize: CGSize(width: 200, height: 200),
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
}



extension ProductRegisterVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        selectedData.count
    }
    
    // 컬렉션 뷰 셀에 대한 설정
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cellId = String(describing: "SelectedImageCell")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! SelectedImageCell
        
        cell.selectedImg.image = self.userSelectedImages[indexPath.row]
        //        print("indexpath = \(indexPath.row)")
        //        cell.cancelImgBtn.tag = indexPath.row
        
        return cell
    }
    
    //선택된 이미지취소(x) 버튼 클릭시 이벤트
    @objc func cancelImg(sender: UIButton){
        let alert = UIAlertController(title: "FleaMarket", message: "이미지를 삭제하시겠습니까?", preferredStyle: .alert)
        
        let confirm = UIAlertAction(title: "확인", style: .default, handler: { (_) in
            
            print("tag = \(sender.tag)")
            print("selectedData = \(self.selectedData)")
            self.productImgView.deleteItems(at: [IndexPath.init(row: sender.tag, section: 0)])
            self.selectedData.remove(at: sender.tag)
            print(sender.tag, "번째 사진 삭제")
            self.selectedCount -= 1
            
            self.productImgView.reloadData()            
        })
        
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alert.addAction(confirm)
        alert.addAction(cancel)

        self.present(alert, animated: false)
    }
}

