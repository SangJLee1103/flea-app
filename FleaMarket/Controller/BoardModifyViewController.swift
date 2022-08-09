//
//  BoardModifyViewController.swift
//  FleaMarket
//
//  Created by 이상준 on 2022/08/08.
//

import Foundation
import UIKit

class BoardModifyViewController: UIViewController {
    
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet var titleField: UITextField!
    @IBOutlet var descriptionField: UITextView!
    @IBOutlet var startField: UIDatePicker!
    @IBOutlet var placeField: UITextField!
    
    let token = Keychain.read(key: "accessToken")
    var boardInfo = BoardModel()
    
    var startTime: String = ""
    var photo: Data? = Data()
    
    let imagePickerController = UIImagePickerController()
    
    let placeholder = " 상세 내용을 적어주세요!!"
    let alertController = UIAlertController(title: "올릴 방식을 선택하세요", message: "사진 찍기 또는 앨범에서 선택", preferredStyle: .actionSheet)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "게시글 수정"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .plain, target: self, action: #selector(onUpdateBtn(_:)))
        
        thumbnail.layer.cornerRadius = 15
        startField.contentHorizontalAlignment = .center
        
        enrollAlertEvent()
        
        imagePickerController.delegate = self
        addGestureRecognizer()
        
        descriptionField.delegate = self
        
        // 초기 UI 함수 호출
        configureUI()
    }
    
    // MARK: -카메라 혹은 사진 앨범 라이브러리 선택 Alert
    func enrollAlertEvent() {
        let photoLibraryAlertAction = UIAlertAction(title: "사진 앨범", style: .default) {
            (action) in
            self.openAlbum()
        }
        let cameraAlertAction = UIAlertAction(title: "카메라", style: .default) {(action) in
            self.openCamera()
        }
        let cancelAlertAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        self.alertController.addAction(photoLibraryAlertAction)
        self.alertController.addAction(cameraAlertAction)
        self.alertController.addAction(cancelAlertAction)
        
        guard let alertControllerPopoverPresentationController
                = alertController.popoverPresentationController
        else {return}
        
        prepareForPopoverPresentation(alertControllerPopoverPresentationController)
    }
    
    // MARK: -날짜 String으로 포멧
    @IBAction func selectDate(_ sender: UIDatePicker) {
        let datePickerView = sender
        
        let formatter = DateFormatter() // DateFormatter 클래스 상수 선언
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss EEE" // formatter의 dateFormat 속성을 설정
        
        startTime = formatter.string(from: datePickerView.date)
    }

    // MARK: - 이미지를 추출하는 함수
    func getThumbnailImage() -> UIImage {
        let board = self.boardInfo
        
        if let savedImage = board.thumbnailImage {
            return savedImage
        } else {
            let url: URL! = URL(string: "http://localhost:3000/\(board.imgPath!)")
            let imageData = try! Data(contentsOf: url)
            board.thumbnailImage = UIImage(data: imageData)
            
            return board.thumbnailImage!
        }
    }
    
    // MARK: - 현재 게시글에 대한 정보
    func configureUI() {
        let data = self.getThumbnailImage().jpegData(compressionQuality: 1.0)
            
        self.photo = data!
        self.thumbnail.image = self.getThumbnailImage()
        self.titleField.text = self.boardInfo.topic
        self.placeField.text = self.boardInfo.place
        self.descriptionField.text = self.boardInfo.description
    }
    
    // MARK: - 작성 버튼 이벤트
    @objc func onUpdateBtn(_ sender: Any) {
        guard let url = URL(string: "http://localhost:3000/board/\(boardInfo.writer!)/\(boardInfo.id!)") else { return }
        
        let topic = self.titleField?.text
        let place = self.placeField?.text
        let start = startTime
        let description = self.descriptionField?.text
        
        //Json 객체로 전송할 딕셔너리
        let parameters = [
            "topic" : topic!,
            "place" : place!,
            "start" : start,
            "description" : description!
        ] as [String : Any]
        
        let boundary = "Boundary-\(UUID().uuidString)"
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token!)", forHTTPHeaderField: "Authorization")
        
        
        var uploadData = Data()
        let imgDataKey = "img"
        let boundaryPrefix = "--\(boundary)\r\n"
        
        for (key, value) in parameters {
            uploadData.append(boundaryPrefix.data(using: .utf8)!)
            uploadData.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            uploadData.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        uploadData.append(boundaryPrefix.data(using: .utf8)!)
        uploadData.append("Content-Disposition: form-data; name=\"\(imgDataKey)\"; filename=\"\("Img").png\"\r\n".data(using: .utf8)!)
        uploadData.append("Content-Type: \("image/png")\r\n\r\n".data(using: .utf8)!)
        uploadData.append(photo!)
        uploadData.append("\r\n".data(using: .utf8)!)
        uploadData.append("--\(boundary)--".data(using: .utf8)!)
        
        do{
            //URLSession 객체를 통해 전송, 응답값 처리
            URLSession.shared.uploadTask(with: request, from: uploadData) { (data: Data?, response: URLResponse?, error: Error?) in
                DispatchQueue.main.async() {
                    // 서버로부터 응답된 스트링 표시
                    do {
                        let object = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary
                        guard let jsonObject = object else { return }
                        
                        //response 데이터 획득, utf8인코딩을 통해 string형태로 변환
                        let status = (response as? HTTPURLResponse)?.statusCode ?? 0
                        
                        // JSON 결과값을 추출
                        let message = jsonObject["message"] as? String //String 타입으로 다운캐스팅
                        let errorArray = jsonObject["message"] as? Array<NSDictionary>
                        let error = errorArray?[0]["msg"] as? String
                        
                        // 성공
                        if (status == 201) {
                            let writeAlert = UIAlertController(title: "Flea Market", message: message, preferredStyle: .alert)
                            let action = UIAlertAction(title: "OK", style: .default){ (_) in
                                self.navigationController?.popToRootViewController(animated: true)
                            }
                            writeAlert.addAction(action)
                            self.present(writeAlert, animated: true, completion: nil)
                        } else if (status == 403) {
                            let duplicationAlert = UIAlertController(title: "Flea Market", message: message, preferredStyle: .alert)
                            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                            duplicationAlert.addAction(action)
                            self.present(duplicationAlert, animated: true, completion: nil)
                        }else { // 실패
                            let checkAlert = UIAlertController(title: "Flea Market", message: error, preferredStyle: .alert)
                            
                            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                            checkAlert.addAction(action)
                            self.present(checkAlert, animated: true, completion: nil)
                        }
                    } catch let e as NSError {
                        print("An error has occured while parsing JSONObject: \(e.localizedDescription)")
                    }
                }
            }.resume()
        }
    }
}

// MARK: - 텍스트 뷰 델리게이트
extension BoardModifyViewController: UITextViewDelegate {
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
}


// MARK: - 이미지 선택 클릭시 밑에서 올라오는 팝오버 프리젠테이션 델리게이트
extension BoardModifyViewController: UIPopoverPresentationControllerDelegate {
    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        
        if let popoverPresentationController =
            self.alertController.popoverPresentationController {
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect
            = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverPresentationController.permittedArrowDirections = []
        }
        
    }
}

// MARK: - 이미지 피커 컨트롤러 네비게이션 컨트롤러 델리게이트
extension BoardModifyViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func openAlbum() {
        self.imagePickerController.sourceType = .photoLibrary
        present(self.imagePickerController, animated: false, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage]
            as? UIImage {
            
            thumbnail?.image = image
            //이미지 사이즈 조절
            let newImageRect = CGRect(x: 0, y: 0, width: 200, height: 200)
            UIGraphicsBeginImageContext(CGSize(width: 200, height: 200))
            image.draw(in: newImageRect)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()?.withRenderingMode(.alwaysOriginal)
            UIGraphicsEndImageContext()
            
            let data = newImage!.jpegData(compressionQuality: 1.0)
            self.photo = data!
        }
        else {
            print("error detected in didFinishPickinMediaWithInfo method")
        }
        dismiss(animated: true, completion: nil) // 반드시 dismiss 하기.
    }
    
    func openCamera() {
        if (UIImagePickerController.isSourceTypeAvailable(.camera)) {
            self.imagePickerController.sourceType = .camera
            present(self.imagePickerController, animated: false, completion: nil)
        }
        else {
            print ("Camera's not available as for now.")
        }
    }
    
    
    func addGestureRecognizer() {
        let tapGestureRecognizer
        = UITapGestureRecognizer(target: self,
                                 action: #selector(self.tappedUIImageView(_:)))
        self.thumbnail.addGestureRecognizer(tapGestureRecognizer)
        self.thumbnail.isUserInteractionEnabled = true
    }
    
    
    // 이미지 뷰 탭 했을 때 이벤트
    @objc func tappedUIImageView(_ gesture: UITapGestureRecognizer) {
        if self.photo?.count == 0 {
            self.present(alertController, animated: true, completion: nil)
        }else {
            self.photo?.count = 0
            self.thumbnail.image = UIImage(named: "camera")
        }
    }
}
