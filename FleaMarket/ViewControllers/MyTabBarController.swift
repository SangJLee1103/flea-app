//
//  MainViewController.swift
//  FleaMarket
//
//  Created by 이상준 on 2022/04/19.
//

import UIKit

class MyTabBarController: UITabBarController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if Keychain.read(key: "accessToken") != nil {
            
        }
    }
}

