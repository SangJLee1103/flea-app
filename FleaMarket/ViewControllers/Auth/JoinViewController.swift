//
//  JoinViewController.swift
//  FleaMarket
//
//  Created by 이상준 on 2022/04/15.
//

import UIKit
import Foundation

class JoinViewController: UIViewController {
    
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
        
        self.emailField.delegate = self
        self.pwField.delegate = self
        self.nicknameField.delegate = self
        self.phoneField.delegate = self
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
            guard let url = URL(string: "\(Network.url)/member/join") else {
                print("Cannot create URL!")
                return
            }
            
            let joinUser = JoinModel(id: self.emailField?.text, password: self.pwField?.text, nickname: self.nicknameField?.text, phone: self.phoneField?.text)
            guard let uploadData = try? JSONEncoder().encode(joinUser)
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
        guard let email = emailField.text else { return }
        guard let password = pwField.text else { return }
        guard let nickname = nicknameField.text else { return }
        guard let phone = phoneField.text else { return }
        
        MemberService.join(email: email, password: password, nickname: nickname, phone: phone) { response in
            switch response {
            case.success((let result, let status)):
                
                if status == 201 {
                    DispatchQueue.main.async {
                        self.clearLabel()
                        let joinAlert = UIAlertController(title: "Flea Market", message: result.message[0].msg, preferredStyle: .alert)

                        let action = UIAlertAction(title: "OK", style: .default, handler: { _ in self.navigationController?.popViewController(animated: true)})
                        joinAlert.addAction(action)
                        self.present(joinAlert, animated: true, completion: nil)
                    }
                } else {
                    print("ㅗ")
                }
                
            case.failure(_):
                print("Error")
            }
        }
    }
}

extension JoinViewController: UITextFieldDelegate {
    
    //화면 터치시 키보드 내림
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // TextField 비활성화
        return true
    }
}