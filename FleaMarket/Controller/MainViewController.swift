//
//  MainViewController.swift
//  FleaMarket
//
//  Created by 이상준 on 2022/04/19.
//

import UIKit

class MainViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let token = Keychain.read(key: "accessToken")
        print("MainViewController: \(token!)")
    }
}
