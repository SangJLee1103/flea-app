//
//  MyUploadItemViewController.swift
//  FleaMarket
//
//  Created by 이상준 on 2022/06/04.
//

import Foundation
import UIKit

class MyProductViewController: UITableViewController {
    
    let token = Keychain.read(key: "accessToken")
    var item: NSArray = []
    
    override func viewDidLoad() {
        self.navigationItem.title = "판매목록"
        self.dataParsing()
    }
    
    lazy var productList: [ProductModel] = {
        var datalist = [ProductModel]()
        return datalist
    }()
    
    // 상품 데이터 파싱 함수
    func dataParsing(){
        for row in item{
            let r = row as! NSDictionary
            
            let myItem = ProductModel()
            
            myItem.id = r["id"] as? Int
            myItem.costPrice = r["cost_price"] as? Int
            myItem.sellingPrice = r["selling_price"] as? Int
            myItem.description = r["description"] as? String
            myItem.productName = r["name"] as? String
            myItem.boardId = r["board_id"] as? Int
            myItem.sellerName = r["user_id"] as? String
            myItem.createdAt = r["created_at"] as? String
            myItem.like = r["Likes"] as? NSArray
            myItem.imgPath = r["img"] as? String
            
            self.productList.append(myItem)
        }
    }
    
    // 이미지를 추출하는 함수
    func getThumbnailImage(_ index: Int) -> UIImage {
        let item = self.productList[index]
        
        if let savedImage = item.thumbnailImage {
            return savedImage
        } else {
            let imgParse = item.imgPath!.split(separator:",")
            let url: URL! = URL(string: "http://172.30.1.63:3000/\(imgParse[0])")
            let imageData = try! Data(contentsOf: url)
            item.thumbnailImage = UIImage(data: imageData)
            
            return item.thumbnailImage!
        }
    }
    
    // 상품 수정 페이지로 이동하는 함수
    func moveModifyViewController(_ row: ProductModel) {
        guard let productModifyVC = self.storyboard?.instantiateViewController(withIdentifier: "ProductModifyViewController") as? ProductModifyViewController else { return }
        productModifyVC.productInfo = row
        self.navigationController?.pushViewController(productModifyVC, animated: true)
    }
    
    
    // 상품 삭제 API 호출
    func callDeleteAPI(_ row: ProductModel) {
        guard let url = URL(string: "http://172.30.1.63:3000/product/\(row.id!)") else { return }
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
            
            do {
                let object = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary
                guard let jsonObject = object else { return }
                //response 데이터 획득, utf8인코딩을 통해 string형태로 변환
                // JSON 결과값을 추출
                let data = jsonObject["message"] as! String
                // 서버로부터 응답된 스트링 표시
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Flea Market", message: data, preferredStyle: .alert)
                    let action = UIAlertAction(title: "확인", style: .default, handler: nil)
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }
            }catch let e as NSError {
                print("An error has occured while parsing JSONObject: \(e.localizedDescription)")
            }
        }
        task.resume()
        
    }
    
    // MARK: - 테이블 뷰가 생성해야 할 행의 개수를 반환하는 메소드
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productList.count
    }
    
    // MARK: -  각 행이 화면에 표현해야 할 내용을 구성하는 메소드
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row: ProductModel = self.productList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell") as! ItemCell
        
        cell.itemImg.layer.cornerRadius = 5
        cell.itemImg?.image = self.getThumbnailImage(indexPath.row)
        cell.itemName?.text = row.productName
        cell.price?.text = "\(row.sellingPrice!)원"
        cell.createdAt?.text = "\(row.createdAt!)"
        cell.likeCount?.text = "\(String(describing: (row.like?.count)!))"
        
        return cell
    }
    
    
    // MARK: - 테이블 뷰 셀 스와이핑 이벤트
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let row = self.productList[indexPath.row]
        
        let modify = UIContextualAction(style: .normal, title: "Modify") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            self.moveModifyViewController(row)
            success(true)
        }
        modify.backgroundColor = .systemGray
        
        
        let delete = UIContextualAction(style: .normal, title: "Delete") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in

            self.callDeleteAPI(row)
            
            DispatchQueue.main.async {
                self.productList.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            success(true)
        }
        delete.backgroundColor = .systemRed
        
        //actions배열 인덱스 0이 오른쪽에 붙어서 나옴
        return UISwipeActionsConfiguration(actions:[delete, modify])
    }
    
    // MARK: - 행을 삭제하는 메소드
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            
            
            
        } else if editingStyle == .insert {
            
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    }
}
