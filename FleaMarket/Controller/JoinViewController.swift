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
    }
    
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
                        
                        //response 데이터 획득, utf8인코딩을 통해 string형태로 변환
                        let status = (response as? HTTPURLResponse)?.statusCode ?? 0
                       
                        // JSON 결과값을 추출
                        let message = jsonObject["message"] as? String //String 타입으로 다운캐스팅
                        let error = jsonObject["message"] as? Array<NSDictionary>
                        let duplication = jsonObject["message"] as? String
                        
                        if status == 201 {
                            self.clearLabel()
                            print("성공")
                            let joinAlert = UIAlertController(title: "Flea Market", message: message, preferredStyle: .alert)
                            
                            let action = UIAlertAction(title: "OK", style: .default, handler: { _ in self.navigationController?.popViewController(animated: true)})
                            joinAlert.addAction(action)
                            self.present(joinAlert, animated: true, completion: nil)
                            self.clearJoinField()
                        }else if status == 403{
                            self.clearLabel()
                            let duplicationAlert = UIAlertController(title: "Flea Market", message: message, preferredStyle: .alert)
                            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                            duplicationAlert.addAction(action)
                            self.present(duplicationAlert, animated: true, completion: nil)
                        }else {
                            self.clearLabel()
                            print("데이터 검사해!")
                            print(((((error?[0])!)["msg"]!) as? String)!)
                            
                            
                            for i in 0 ..< (error?.count)! {
                                if(((error?[i])!)["param"]! as? String == "id"){
                                    self.emailError.text = ((((error?[i])!)["msg"]!) as? String)!
                                    break;
                                }
                            }
                            
                            for i in 0 ..< (error?.count)! {
                                if(((error?[i])!)["param"]! as? String == "password"){
                                    self.pwError.text = ((((error?[i])!)["msg"]!) as? String)!
                                    break
                                }
                            }
                            
                            for i in 0 ..< (error?.count)! {
                                if(((error?[i])!)["param"]! as? String == "nickname"){
                                    self.nicknameError.text = ((((error?[i])!)["msg"]!) as? String)!
                                    break
                                }
                            }
                            
                            for i in 0 ..< (error?.count)! {
                                if(((error?[i])!)["param"]! as? String == "phone"){
                                    self.phoneError.text = ((((error?[i])!)["msg"]!) as? String)!
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
}
