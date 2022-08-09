//
//  ViewController.swift
//  FleaMarket
//
//  Created by 이상준 on 2022/04/15.
//

import UIKit
import WebKit

class LoginViewController: UIViewController {
   

    @IBOutlet var logoImg: UIImageView!
    @IBOutlet var emailField: UITextField!
    @IBOutlet var pwField: UITextField!
    
    
    @IBOutlet var moveJoinBtn: UIButton!
    @IBOutlet var btnForLogin: UIButton!
    
    var get: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logoImg.image = UIImage(named:"build.png")
        
        // 화면 터치 시 키보드 숨김
        self.hideKeyboard()
        
        //상단 네비게이션 바 hidden
        self.navigationController?.isNavigationBarHidden = true
    }
    
    // MARK: - 로그인 버튼 액션 함수
    @IBAction func onLoginBtn(_ sender: UIButton) {
        callLoginAPI()
    }
    
    // MARK: - 로그인 API 호출 함수
    func callLoginAPI(){
        do{
            
            guard let url = URL(string: "http://localhost:3000/member/login") else
            {
                print("Cannot create URL!")
                return
            }
            
            let loginUser = LoginModel(id: self.emailField.text!, password: self.pwField.text!)
            guard let uploadData = try? JSONEncoder().encode(loginUser)
            else { return }
            
            //URLRequest 객체를 정의
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            //URLSession 객체를 통해 전송, 응답값 처리
            let task = URLSession.shared.uploadTask(with: request, from: uploadData) { (data, response, error) in
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

