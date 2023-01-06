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
        DispatchQueue.main.async {
            self.emailField.text = ""
            self.pwField.text = ""
            self.nicknameField.text = ""
            self.phoneField.text = ""
        }
    }
    
    func clearLabel(){
        DispatchQueue.main.async {
            self.emailError.text = ""
            self.pwError.text = ""
            self.nicknameError.text = ""
            self.phoneError.text = ""
        }
    }
    
    //회원가입 기능 액션 함수
    @IBAction func onJoinBtn(_ sender: UIButton) {
        guard let email = emailField.text else { return }
        guard let password = pwField.text else { return }
        guard let nickname = nicknameField.text else { return }
        guard let phone = phoneField.text else { return }
        
        MemberService.join(email: email, password: password, nickname: nickname, phone: phone) { [weak self] response in
            switch response {
            case.success((let result, let status)):
                if status == 201 {
                    DispatchQueue.main.async {
                        self?.clearLabel()
                        let joinAlert = UIAlertController(title: "Flea Market", message: result.message[0].msg, preferredStyle: .alert)

                        let action = UIAlertAction(title: "OK", style: .default, handler: { _ in self?.navigationController?.popViewController(animated: true)})
                        joinAlert.addAction(action)
                        self?.present(joinAlert, animated: true, completion: nil)
                    }
                } else {
                    self?.clearLabel()
                    DispatchQueue.main.async {
                        for i in 0 ..< result.message.count {
                            if result.message[i].param == "id" {
                                self?.emailError.text = result.message[i].msg
                                continue
                            } else if result.message[i].param == "password" {
                                self?.pwError.text = result.message[i].msg
                                continue
                            } else if result.message[i].param == "nickname" {
                                self?.nicknameError.text = result.message[i].msg
                                continue
                            } else {
                                self?.phoneError.text = result.message[i].msg
                                break
                            }
                        }
                    }
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
