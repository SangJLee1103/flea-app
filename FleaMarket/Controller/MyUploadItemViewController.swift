//
//  MyUploadItemViewController.swift
//  FleaMarket
//
//  Created by 이상준 on 2022/06/04.
//

import Foundation
import UIKit

class MyUploadItemViewController: UITableViewController {
 
    let token = Keychain.read(key: "accessToken")
    var item: NSArray = []
    
    override func viewDidLoad() {
        self.databinding()
    }
    
    let myItem = ProductResponse()
    
    lazy var productList: [ProductResponse] = {
        var datalist = [ProductResponse]()
        return datalist
    }()
    
    func databinding(){
        for row in item{
            let r = row as! NSDictionary
            
            myItem.id = r["id"] as? Int
            myItem.costPrice = r["cost_price"] as? Int
            myItem.sellingPrice = r["selling_price"] as? Int
            myItem.description = r["description"] as? String
            myItem.productName = r["name"] as? String
            myItem.costPrice = r["cost_price"] as? Int
            myItem.sellerName = r["user_id"] as? String
            myItem.createdAt = r["created_at"] as? String
            myItem.like = r["Likes"] as? NSArray
            myItem.productImg = r["img"] as? String
            
            self.productList.append(myItem)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = self.productList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyUploadItemCell") as! MyUploadItemCell
        
        let imgParse = row.productImg!.split(separator:",")
        
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        row.createdAt = formatter.string(from: Date())
        
        cell.itemImg.layer.cornerRadius = 5
        cell.itemImg?.image = UIImage(data: try! Data(contentsOf: URL(string: "http://localhost:3000/\(imgParse[0])")!))
        cell.itemName?.text = row.productName
        cell.price?.text = "\(row.sellingPrice!)원"
        cell.createdAt?.text = "\(String(describing: row.createdAt!))"
        cell.likeCount?.text = "\(String(describing: (row.like?.count)!))"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let row = self.productList[indexPath.row]
            
            productList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            guard let url = URL(string: "http://localhost:3000/product/\(row.id!)") else { return }
            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            //HTTP 메시지 헤더
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(token!)", forHTTPHeaderField: "Authorization")
                
            //URLSession 객체를 통해 전송, 응답값 처리
            
            //URLSession 객체를 통해 전송, 응답값 처리
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let e = error{
                    NSLog("An error has occured: \(e.localizedDescription)")
                    return
                }
                    // 서버로부터 응답된 스트링 표시
                DispatchQueue.main.async {
                    do {
                        let object = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary
                        guard let jsonObject = object else { return }
                        //response 데이터 획득, utf8인코딩을 통해 string형태로 변환
                        // JSON 결과값을 추출
                        let data = jsonObject["message"] as! String
                        
                        let alert = UIAlertController(title: "Flea Market", message: data, preferredStyle: .alert)
                        let action = UIAlertAction(title: "확인", style: .default, handler: nil)
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil)
                        
                     
                    } catch let e as NSError {
                        print("An error has occured while parsing JSONObject: \(e.localizedDescription)")
                    }
                }
            }
            task.resume()
        } else if editingStyle == .insert {
        
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
}
