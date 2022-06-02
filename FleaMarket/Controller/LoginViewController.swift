//
//  ViewController.swift
//  FleaMarket
//
//  Created by 이상준 on 2022/04/15.
//

import UIKit
import WebKit

class LoginViewController: UIViewController {
   

    @IBOutlet var emailField: UITextField!
    
    @IBOutlet var pwField: UITextField!
    //로그인 버튼
    @IBOutlet var btnForLogin: UIButton!
    
    var get: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
        // Do any additional setup after loading the view.
        
        //상단 네비게이션 바 hidden
        self.navigationController?.isNavigationBarHidden = true
    }
    
    
    //로그인 액션 함수
    @IBAction func onLoginBtn(_ sender: UIButton) {
        
        do{
            let id = self.emailField?.text
            let pw = self.pwField?.text
           
            //Json 객체로 전송할 딕셔너리
            let body = ["id" : id, "password" : pw]
            let bodyData = try! JSONSerialization.data(withJSONObject: body, options: [])
            
            let url = URL(string: "http://localhost:3000/member/login")
            
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
                        let message = jsonObject["message"] as? String //String 타입으로 다운캐스팅
                        let accessToken = jsonObject["accessToken"] as? String
                        
                        if (status == 200) {
                            let loginAlert = UIAlertController(title: "Flea Market", message: message, preferredStyle: .alert)

                            let action = UIAlertAction(title: "OK", style: .default, handler: { _ in
                                self.performSegue(withIdentifier: "mainSegue", sender: self)
                            })
                            loginAlert.addAction(action)
                            Keychain.create(key: "accessToken", token: accessToken!)
                            UserDefaults.standard.set(accessToken!, forKey: "accessToken")
                            self.present(loginAlert, animated: true, completion: nil)
                        } else {
                            let checkAlert = UIAlertController(title: "Flea Market", message: message, preferredStyle: .alert)
                            
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

