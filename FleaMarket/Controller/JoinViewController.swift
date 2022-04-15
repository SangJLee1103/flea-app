//
//  JoinViewController.swift
//  FleaMarket
//
//  Created by 이상준 on 2022/04/15.
//

import UIKit

class JoinViewController: UIViewController {
    
    //이미 계정이 있으신가요? 버튼
    @IBOutlet var btnForLoginViewController: UIButton!
    
    
    @IBOutlet var emailField: UITextField!
    
    @IBOutlet var pwField: UITextField!
    
    @IBOutlet var nicknameField: UITextField!
    
    @IBOutlet var phoneField: UITextField!
    
    //회원가입 버튼
    @IBOutlet var btnForJoin: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func onLoginViewControllerClicked(_ sender: UIButton) {
        print("click")
        
        //네비게이션 뷰 컨트롤러 POP
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    //회원가입 기능 액션 함수
    @IBAction func onJoinBtn(_ sender: UIButton) {
        
        do{
            let id = self.emailField.text!
            let pw = self.pwField.text!
            let nickname = self.nicknameField.text!
            let phone = self.phoneField.text!
            
            //Json 객체로 전송할 딕셔너리
            let body = ["id" : id, "password" : pw, "nickname" : nickname, "phone" : phone]
            let bodyData = try! JSONSerialization.data(withJSONObject: body, options: [])
            
            let url = URL(string: "http://localhost:3000/member/join")
            
            //URLRequest 객체를 정의
            var request = URLRequest(url: url!)
            request.httpMethod = "POST"
            request.httpBody = bodyData
            
            //HTTP 메시지 헤더
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
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
                        let status = (response as? HTTPURLResponse)?.statusCode ?? 0
                       
                        // JSON 결과값을 추출
                        let message = jsonObject["message"] as? String
//                        let timestamp = jsonObject["timestamp"] as? String
//                        let userId = jsonObject["userId"] as? String
//                        let name = jsonObject["name"] as? String
//
                        if status == 201 {
                            print("성공")
                            print((message!))
                            
                        }else {
                            print("데이터 검사해!")
                            print((message!))
                        }
//                        // 결과가 성공일 경우
//                        if result == "SUCCESS" {
//                            self.responseView.text = "아이디: \(userId!)" + "\n"
//                            + "이름: \(name!)" + "\n"
//                            + "응답결과: \(result!)" + "\n"
//                            + "응답시간: \(timestamp!)" + "\n"
//                            + "요청방식: x-www-form-urlencoded"
//                        }
                    } catch let e as NSError {
                        print("An error has occured while parsing JSONObject: \(e.localizedDescription)")
                    }
                }
            }
            task.resume()
        }
    }
}
