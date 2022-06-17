//
//  MyLikeItemViewController.swift
//  FleaMarket
//
//  Created by 이상준 on 2022/06/13.
//

import Foundation
import UIKit

class MyLikeItemViewController: UITableViewController {
        
    var data: NSArray = []
    
    lazy var productList: [ProductResponse] = {
        var datalist = [ProductResponse]()
        return datalist
    }()
    
    override func viewDidLoad() {
        print(data)
    }
    
    func databind(){
       
    }
}
