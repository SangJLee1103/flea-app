//
//  MyLikeItemViewController.swift
//  FleaMarket
//
//  Created by 이상준 on 2022/06/13.
//

import Foundation
import UIKit

class MyLikeViewController: UITableViewController {
    
    let token = Keychain.read(key: "accessToken")
    var likeItem: [LikesModel] = []
    
    lazy var productList: [ProductModel] = {
        var datalist = [ProductModel]()
        return datalist
    }()
    
    override func viewDidLoad() {
        self.navigationItem.title = "관심목록"
//        self.dataParsing()
    }
    
//    func dataParsing(){
//        for count in 0 ..< likeItem.count {
//            let item = likeItem[count]["Product"] as! NSDictionary
            //            let myLikeItem = ProductModel()
            //
            //            myLikeItem.id = item["id"] as? Int
            //            myLikeItem.costPrice = item["cost_price"] as? Int
            //            myLikeItem.sellingPrice = item["selling_price"] as? Int
            //            myLikeItem.description = item["description"] as? String
            //            myLikeItem.productName = item["name"] as? String
            //            myLikeItem.costPrice = item["cost_price"] as? Int
            //            myLikeItem.boardTitle = item["board_title"] as? String
            //            myLikeItem.sellerName = item["user_id"] as? String
            //            myLikeItem.createdAt = item["created_at"] as? String
            //            myLikeItem.like = item["Likes"] as? NSArray
            //            myLikeItem.imgPath = item["img"] as? String
            //
            //            self.productList.append(myLikeItem)
//        }
//    }
    
    // 이미지를 추출하는 함수
//    func getThumbnailImage(_ index: Int) -> UIImage {
//        let item = self.productList[index]
        
        //        if let savedImage = item.thumbnailImage {
        //            return savedImage
        //        } else {
        //            let imgParse = item.imgPath!.split(separator:",")
        //            let url: URL! = URL(string: "\(Network.url)/\(imgParse[0])")
        //            let imageData = try! Data(contentsOf: url)
        //            item.thumbnailImage = UIImage(data: imageData)
        //
        //            return item.thumbnailImage!
        //        }
//    }
    
    // 좋아요 취소
    func callDeleteLike(_ row: ProductModel) {
        //        do{
        //            guard let url =  URL(string: "\(Network.url)/likes/\(row.id!)/count") else { return }
        //
        //            //URLRequest 객체를 정의
        //            var request = URLRequest(url: url)
        //            request.httpMethod = "DELETE"
        //
        //            //HTTP 메시지 헤더
        //            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        //            request.addValue("Bearer \(token!)", forHTTPHeaderField: "Authorization")
        //
        //            //URLSession 객체를 통해 전송, 응답값 처리
        //            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        //                if let e = error{
        //                    NSLog("An error has occured: \(e.localizedDescription)")
        //                    return
        //                }
        //            }
        //            task.resume()
        //
        //            DispatchQueue.main.async {
        //                let alert = UIAlertController(title: "Flea Market", message: "좋아요 취소되었습니다.", preferredStyle: .alert)
        //                let action = UIAlertAction(title: "확인", style: .default, handler: nil)
        //                alert.addAction(action)
        //                self.present(alert, animated: true, completion: nil)
        //            }
        //        }
    }
    
    
    // MARK: - 테이블 뷰가 생성해야 할 행의 개수를 반환하는 메소드
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productList.count
    }
    
    // MARK: -  각 행이 화면에 표현해야 할 내용을 구성하는 메소드
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row: ProductModel = self.productList[indexPath.row]
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell") as! ItemCell
        
        //        cell.itemImg.layer.cornerRadius = 5
        //        cell.itemImg?.image = self.getThumbnailImage(indexPath.row)
        //        cell.itemName?.text = row.productName
        //
        //        let priceDecimal = numberFormatter.string(from: NSNumber(value: row.sellingPrice!))
        //        cell.price?.text = "\(priceDecimal ?? "0")원"
        //
        //        cell.createdAt?.text = "\(String(describing: row.boardTitle!))"
        //        cell.likeCount?.text = "\(String(describing: (row.like?.count)!))"
        //
        return cell
    }
    
    // MARK: - 테이블 뷰 스와이핑 버튼(좋아요 취소 기능)
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let row = self.productList[indexPath.row]
        let delete = UIContextualAction(style: .normal, title: "Delete") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            self.callDeleteLike(row)
            
            DispatchQueue.main.async {
                self.productList.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            success(true)
        }
        delete.backgroundColor = .systemRed
        
        //actions배열 인덱스 0이 오른쪽에 붙어서 나옴
        return UISwipeActionsConfiguration(actions:[delete])
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //        guard let productId = self.productList[indexPath.row].id else { return }
        guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "ProductDetailViewController") as? ProductDetailViewController else { return }
        //        nextVC.productId = productId
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
}



