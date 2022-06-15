//
//  MyUploadItemViewController.swift
//  FleaMarket
//
//  Created by 이상준 on 2022/06/04.
//

import Foundation
import UIKit

class MyUploadItemViewController: UITableViewController {
 
    var item: NSArray = []
    
    override func viewDidLoad() {
        self.databinding()
    }
    
    lazy var productList: [ProductResponse] = {
        var datalist = [ProductResponse]()
        return datalist
    }()
    
    func databinding(){
        for row in item{
            let r = row as! NSDictionary
            
            let myItem = ProductResponse()
            
            myItem.id = r["id"] as? Int
            myItem.costPrice = r["cost_price"] as? Int
            myItem.sellingPrice = r["selling_price"] as? Int
            myItem.description = r["description"] as? String
            myItem.productName = r["name"] as? String
            myItem.costPrice = r["cost_price"] as? Int
            myItem.sellerName = r["user_id"] as? String
            myItem.like = r["Likes"] as? NSArray
            
            self.productList.append(myItem)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return item.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = self.productList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyUploadItemCell") as! MyUploadItemCell
        
        cell.itemName?.text = row.productName
        cell.price?.text = "\(row.sellingPrice!)"
        cell.likeCount?.text = "\(String(describing: (row.like?.count)!))"
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
}
