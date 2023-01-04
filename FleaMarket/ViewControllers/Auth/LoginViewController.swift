//
//  ViewController.swift
//  FleaMarket
//
//  Created by 이상준 on 2022/04/15.
//

import UIKit

class LoginViewController: UIViewController {
    
    
    @IBOutlet var logoImg: UIImageView!
    @IBOutlet var emailField: UITextField!
    @IBOutlet var pwField: UITextField!
    
    @IBOutlet var moveJoinBtn: UIButton!
    
    @IBOutlet var btnForLogin: UIButton!
    
    var get: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 화면 터치 시 키보드 숨김
        self.emailField.delegate = self
        self.pwField.delegate = self
        
        //상단 네비게이션 바 hidden
        self.navigationController?.isNavigationBarHidden = true
    }
    
    // MARK: - 로그인 버튼 액션
    @IBAction func handleLogin(_ sender: UIButton) {
        guard let email = emailField.text else { return }
        guard let password = pwField.text else { return }
        
        MemberService.login(email: email, password: password) { response in
            switch response {
            case .success(let result):
                guard let message = result.message else { return }
                if let accessToken = result.accessToken {
                    DispatchQueue.main.async {
                        let loginAlert = UIAlertController(title: "Flea Market", message: message, preferredStyle: .alert)
                        
                        let action = UIAlertAction(title: "OK", style: .default, handler: { _ in
                            self.performSegue(withIdentifier: "mainSegue", sender: self)
                        })
                        loginAlert.addAction(action)
                        UserDefaults.standard.set(accessToken, forKey: "accessToken")
                        Keychain.create(key: "accessToken", token: accessToken)
                        self.present(loginAlert, animated: true, completion: nil)
                    }
                } else {
                    DispatchQueue.main.async {
                        let checkAlert = UIAlertController(title: "Flea Market", message: message, preferredStyle: .alert)
                        
                        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                        checkAlert.addAction(action)
                        self.present(checkAlert, animated: true, completion: nil)
                    }
                }
            case .failure(_):
                print("Error")
            }
        }
    }
}

extension LoginViewController: UITextFieldDelegate {
    
    //화면 터치시 키보드 내림
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // TextField 비활성화
        return true
    }
}

