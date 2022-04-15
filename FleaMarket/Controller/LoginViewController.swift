//
//  ViewController.swift
//  FleaMarket
//
//  Created by 이상준 on 2022/04/15.
//

import UIKit

class LoginViewController: UIViewController {
   

    @IBOutlet var emailField: UITextField!
    
    @IBOutlet var pwField: UITextField!
    //로그인 버튼
    @IBOutlet var btnForLogin: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //상단 네비게이션 바 hidden
        self.navigationController?.isNavigationBarHidden = true
    }
    
    //로그인 액션 함수
    @IBAction func onLoginBtn(_ sender: Any) {
        
    }
    
}

