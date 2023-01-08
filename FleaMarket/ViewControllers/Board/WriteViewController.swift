//
//  WriteViewController.swift
//  FleaMarket
//
//  Created by 이상준 on 2022/05/07.
//

import UIKit
import Photos

class WriteViewController: UIViewController {
    
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet var titleField: UITextField!
    @IBOutlet var descriptionField: UITextView!
    @IBOutlet var startField: UIDatePicker!
    @IBOutlet var placeField: UITextField!
    @IBOutlet var btnForWrite: UIBarButtonItem!
    
    let token = Keychain.read(key: "accessToken")
    var startTime: String = ""
    var photo: Data? = Data()
    
    let imagePickerController = UIImagePickerController()
    
    let placeholder = " 상세 내용을 적어주세요!!"
    let alertController = UIAlertController(title: "올릴 방식을 선택하세요", message: "사진 찍기 또는 앨범에서 선택", preferredStyle: .actionSheet)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titleField.delegate = self
        self.placeField.delegate = self
        
        thumbnail.layer.cornerRadius = 15
        startField.contentHorizontalAlignment = .center
        
        enrollAlertEvent()
        
        imagePickerController.delegate = self
        addGestureRecognizer()
        descriptionField.delegate = self
        descriptionField.text = placeholder
        descriptionField.textColor = #colorLiteral(red: 0.8209919333, green: 0.8216187358, blue: 0.8407624364, alpha: 1)
    }
    
    // MARK: -카메라 혹은 사진 앨범 라이브러리 선택 Alert
    func enrollAlertEvent() {
        let photoLibraryAlertAction = UIAlertAction(title: "사진 앨범", style: .default) {
            (action) in
            self.openAlbum()
        }
        let cancelAlertAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        self.alertController.addAction(photoLibraryAlertAction)
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
        formatter.dateFormat = "yy.MM.dd.(EEEEEE) a hh시 mm분" // formatter의 dateFormat 속성을 설정
        formatter.locale = Locale(identifier:"ko_KR")
        
        startTime = formatter.string(from: datePickerView.date)
    }
    
    // MARK: -나가기 버튼 이벤트
    @IBAction func onExitBtn(_ sender: Any) {
        let alert = UIAlertController(title: "FleaMarket", message: "작성을 취소하시겠습니까?", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        let ok = UIAlertAction(title: "확인", style: .default) { (_) in self.navigationController?.popToRootViewController(animated: true)
        }
        alert.addAction(cancel)
        alert.addAction(ok)
        self.present(alert, animated: false)
    }
    
    // MARK: - 작성 버튼 이벤트
    @IBAction func onWriteBtn(_ sender: Any) {
        guard let topic = self.titleField.text else { return }
        guard let place = self.placeField.text else { return }
        let start = startTime
        guard let description = self.descriptionField.text else { return }
        guard let photo = self.photo else { return }
        
        BoardService.postBoard(topic: topic, place: place, start: start, description: description, photo: photo) { [weak self] response in
            switch response {
            case.success((let result, let status)):
                if status == 201 {
                    DispatchQueue.main.async {
                        let writeAlert = UIAlertController(title: "Flea Market", message: result.message[0].msg, preferredStyle: .alert)
                        let action = UIAlertAction(title: "OK", style: .default){ (_) in
                            let mainVC = self?.navigationController!.viewControllers.first as? MainViewController
                            mainVC?.updateUI()
                            self?.navigationController?.popToRootViewController(animated: true)
                        }
                        writeAlert.addAction(action)
                        self?.present(writeAlert, animated: true, completion: nil)
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
}

extension WriteViewController: UITextFieldDelegate {
    
    //화면 터치시 키보드 내림
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // TextField 비활성화
        return true
    }
}


// MARK: - 텍스트 뷰 델리게이트
extension WriteViewController: UITextViewDelegate {
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


// MARK: - 이미지 선택 클릭시 밑에서 올라오는 팝오버 프리젠테이션 델리게이트
extension WriteViewController: UIPopoverPresentationControllerDelegate {
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
extension WriteViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
