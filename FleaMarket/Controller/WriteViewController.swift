//
//  WriteViewController.swift
//  FleaMarket
//
//  Created by 이상준 on 2022/04/19.
//

import UIKit

class WriteViewController: UIViewController, UITextViewDelegate {
    
    let placeholder = " 자세한 내용을 적어주세요!!"
    
    @IBOutlet var startField: UIDatePicker!
    @IBOutlet var titleField: UITextField!
    @IBOutlet var descriptionField: UITextView!
    
    @IBOutlet var btnForWrite: UIButton!
    
    let token = Keychain.read(key: "accessToken")
    var startTime: String? = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startField.contentHorizontalAlignment = .center
        
        descriptionField.layer.borderWidth = 1.0
        descriptionField.layer.borderColor = UIColor.black.cgColor
        descriptionField.delegate = self
        descriptionField.text = placeholder
        descriptionField.textColor = .lightGray
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
    
    
    @IBAction func selectDate(_ sender: UIDatePicker) {
        let datePickerView = sender
        
        let formatter = DateFormatter() // DateFormatter 클래스 상수 선언
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss EEE" // formatter의 dateFormat 속성을 설정
        
        startTime = formatter.string(from: datePickerView.date)
    }
    
    @IBAction func onWriteBtn(_ sender: UIButton) {
        do{
            let start = startTime!
            let topic = self.titleField?.text
            let description = self.descriptionField?.text
            let password = ""
           
            //Json 객체로 전송할 딕셔너리
            let body = ["start" : start, "topic" : topic, "description" : description, "password" : password]
            let bodyData = try! JSONSerialization.data(withJSONObject: body, options: [])
            
            let url = URL(string: "http://localhost:3000/board/write")
            
            //URLRequest 객체를 정의
            var request = URLRequest(url: url!)
            request.httpMethod = "POST"
            request.httpBody = bodyData
            
            //HTTP 메시지 헤더
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(token!)", forHTTPHeaderField: "Authorization")
            request.setValue(String(bodyData.count), forHTTPHeaderField: "Content-Length")
            
            //URLSession 객체를 통해 전송, 응답값 처리
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let e = error{
                    NSLog("An error has occured: \(e.localizedDescription)")
                    return
                }
                DispatchQueue.main.async() {
                    // 서버로부터 응답된 스트링 표시
                    do {
                        let object = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary
                        guard let jsonObject = object else { return }
                        
                        //response 데이터 획득, utf8인코딩을 통해 string형태로 변환
                        let status = (response as? HTTPURLResponse)?.statusCode ?? 0
                       
                        // JSON 결과값을 추출
                        let message = jsonObject["message"] as? String //String 타입으로 다운캐스팅
                        let error = jsonObject["message"] as? Array<NSDictionary>
                        
                        if (status == 201) {
                            let writeAlert = UIAlertController(title: "Flea Market", message: message, preferredStyle: .alert)

                            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                            writeAlert.addAction(action)
                            self.present(writeAlert, animated: true, completion: nil)
                        } else {
                            let checkAlert = UIAlertController(title: "Flea Market", message: (error?[0])?["msg"] as? String, preferredStyle: .alert)
                            
                            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                            checkAlert.addAction(action)
                            self.present(checkAlert, animated: true, completion: nil)
                        }
                    } catch let e as NSError {
                        print("An error has occured while parsing JSONObject: \(e.localizedDescription)")
                    }
                }
            }
            task.resume()
        }
    }
}
