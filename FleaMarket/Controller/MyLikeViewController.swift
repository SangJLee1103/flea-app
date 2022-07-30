//
//  MyLikeItemViewController.swift
//  FleaMarket
//
//  Created by 이상준 on 2022/06/13.
//

import Foundation
import UIKit

class MyLikeViewController: UITableViewController {
        
    var data: NSArray = []
    
    lazy var productList: [ProductModel] = {
        var datalist = [ProductModel]()
        return datalist
    }()
    
    override func viewDidLoad() {
        print(data)
    }
    
    func databind(){
       
    }
}
