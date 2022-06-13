//
//  JoinViewController.swift
//  FleaMarket
//
//  Created by 이상준 on 2022/04/15.
//

import UIKit
import Foundation

class JoinViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet var logoImg: UIImageView!
    
    //이미 계정이 있으신가요? 버튼
    @IBOutlet var btnForLoginViewController: UIButton!
    
    // 회원가입 데이터 전송 필드
    @IBOutlet var emailField: UITextField!
    @IBOutlet var pwField: UITextField!
    @IBOutlet var nicknameField: UITextField!
    @IBOutlet var phoneField: UITextField!
    
    // 회원가입 에러 출력 라벨
    @IBOutlet var emailError: UILabel!
    @IBOutlet var pwError: UILabel!
    @IBOutlet var nicknameError: UILabel!
    @IBOutlet var phoneError: UILabel!
    
    //회원가입 버튼
    @IBOutlet var btnForJoin: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.isNavigationBarHidden = true
        logoImg.image = UIImage(named:"build.png")
    }
    
    
    // 로그인 페이지 이동 버튼
    @IBAction func onLoginViewControllerClicked(_ sender: UIButton) {
        //네비게이션 뷰 컨트롤러 POP
        self.navigationController?.popViewController(animated: true)
    }
    
    //회원가입 다음 로직 -> 로그인
    func clearJoinField(){
        emailField.text = ""
        pwField.text = ""
        nicknameField.text = ""
        phoneField.text = ""
    }
    
    func clearLabel(){
        emailError.text = ""
        pwError.text = ""
        nicknameError.text = ""
        phoneError.text = ""
    }
    
    // 회원가입 로직
    func callJoinAPI() {
        do{
            guard let url = URL(string: "http://localhost:3000/member/join") else {
                print("Cannot create URL!")
                return
            }

            let user = User(email: self.emailField?.text, password: self.pwField?.text, nickname: self.nicknameField?.text, phoneNumber: self.phoneField?.text)

            
            //Json 객체로 전송할 딕셔너리
            let body = ["id" : user.email, "password" : user.password, "nickname" : user.nickname, "phone" : user.phoneNumber]
            
            //URLRequest 객체를 정의
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try! JSONSerialization.data(withJSONObject: body, options: [])
            
            
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
                      
                        
                        if status == 201 {
                            self.clearLabel()
                            let joinAlert = UIAlertController(title: "Flea Market", message: message, preferredStyle: .alert)
                            
                            let action = UIAlertAction(title: "OK", style: .default, handler: { _ in self.navigationController?.popViewController(animated: true)})
                            joinAlert.addAction(action)
                            self.present(joinAlert, animated: true, completion: nil)
                            self.clearJoinField()
                        }else if status == 403 {
                            self.clearLabel()
                            if(message == "이미 등록된 아이디 혹은 이메일입니다.") {
                                self.emailError.text = message
                            }else if(message == "이미 등록된 닉네임입니다.") {
                                self.nicknameError.text = message
                            }else {
                                self.phoneError.text = message
                            }
                            
                        }else {
                            self.clearLabel()
                            
                            for i in 0 ..< (error?.count)! {
                                if((error?[i])?["param"] as? String == "id"){
                                    self.emailError.text = (((error?[i])?["msg"]) as? String)
                                    break;
                                }
                            }
                            
                            for i in 0 ..< (error?.count)! {
                                if((error?[i])?["param"] as? String == "password"){
                                    self.pwError.text = (((error?[i])?["msg"]) as? String)
                                    break
                                }
                            }
                            
                            for i in 0 ..< (error?.count)! {
                                if((error?[i])?["param"] as? String == "nickname"){
                                    self.nicknameError.text = (((error?[i])?["msg"]) as? String)
                                    break
                                }
                            }
                            
                            for i in 0 ..< (error?.count)! {
                                if((error?[i])?["param"] as? String == "phone"){
                                    self.phoneError.text = (((error?[i])?["msg"]) as? String)
                                    break
                                }
                            }
                        }
                    } catch let e as NSError {
                        print("An error has occured while parsing JSONObject: \(e.localizedDescription)")
                    }
                }
            }
            task.resume()
        }
        
    }
    
    //회원가입 기능 액션 함수
    @IBAction func onJoinBtn(_ sender: UIButton) {
        callJoinAPI()
    }
}
