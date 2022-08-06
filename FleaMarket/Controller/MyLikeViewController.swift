//
//  MyLikeItemViewController.swift
//  FleaMarket
//
//  Created by 이상준 on 2022/06/13.
//

import Foundation
import UIKit

class MyLikeViewController: UITableViewController {
    
    var likeItem: Array<NSDictionary> = []
    
    lazy var productList: [ProductModel] = {
        var datalist = [ProductModel]()
        return datalist
    }()
    
    override func viewDidLoad() {
        self.navigationItem.title = "관심목록"
        self.dataParsing()
    }
    
    func dataParsing(){
        for count in 0 ..< likeItem.count {
            let item = likeItem[count]["Product"] as! NSDictionary
            
            let myLikeItem = ProductModel()
            
            myLikeItem.id = item["id"] as? Int
            myLikeItem.costPrice = item["cost_price"] as? Int
            myLikeItem.sellingPrice = item["selling_price"] as? Int
            myLikeItem.description = item["description"] as? String
            myLikeItem.productName = item["name"] as? String
            myLikeItem.costPrice = item["cost_price"] as? Int
            myLikeItem.sellerName = item["user_id"] as? String
            myLikeItem.createdAt = item["created_at"] as? String
            myLikeItem.like = item["Likes"] as? NSArray
            myLikeItem.thumbnail = item["img"] as? String
            
            self.productList.append(myLikeItem)
            
        }
    }
    
    // 이미지를 추출하는 함수
    func getThumbnailImage(_ index: Int) -> UIImage {
        let item = self.productList[index]
        
        if let savedImage = item.thumbnailImage {
            return savedImage
        } else {
            let imgParse = item.thumbnail!.split(separator:",")
            let url: URL! = URL(string: "http://localhost:3000/\(imgParse[0])")
            let imageData = try! Data(contentsOf: url)
            item.thumbnailImage = UIImage(data: imageData)
            
            return item.thumbnailImage!
        }
    }
    
    // MARK: - 테이블 뷰가 생성해야 할 행의 개수를 반환하는 메소드
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productList.count
    }
    
    // MARK: -  각 행이 화면에 표현해야 할 내용을 구성하는 메소드
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row: ProductModel = self.productList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell") as! ItemCell
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        row.createdAt = formatter.string(from: Date())
        cell.itemImg.layer.cornerRadius = 5
        cell.itemImg?.image = self.getThumbnailImage(indexPath.row)
        cell.itemName?.text = row.productName
        cell.price?.text = "\(row.sellingPrice!)원"
        cell.createdAt?.text = "\(String(describing: row.createdAt!))"
        cell.likeCount?.text = "\(String(describing: (row.like?.count)!))"
        
        return cell
    }
}
