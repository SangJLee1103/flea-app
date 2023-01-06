//
//  ProductCell.swift
//  FleaMarket
//
//  Created by 이상준 on 2022/05/17.
//

import UIKit

class ProductCell: UICollectionViewCell {
    
    var productId: Int = 0
    
    @IBOutlet var img: UIImageView!
    @IBOutlet var likeBtn: UIButton!
    @IBOutlet var sellerName: UILabel!
    @IBOutlet var name: UILabel!
    @IBOutlet var sellingPrice: UILabel!
    
    let token = Keychain.read(key: "accessToken")
    
    
    // 상품 좋아요 UI 적용
    func likeUI() {
        if(likeBtn.tag == 1){
            DispatchQueue.main.async {
                self.likeBtn.configuration?.image = UIImage(systemName: "heart.fill")
            }
        }else {
            DispatchQueue.main.async {
                self.likeBtn.configuration?.image = UIImage(systemName: "heart")
            }
        }
    }
    
    
    
    @IBAction func likeCount(_ sender: UIButton) {
        if likeBtn.tag == 0 {
            likeBtn.configuration?.image = UIImage(systemName: "heart.fill")
            likeBtn.tag = 1
            do{
                guard let url =  URL(string: "\(Network.url)/likes/\(productId)/count") else { return }

                //URLRequest 객체를 정의
                var request = URLRequest(url: url)
                request.httpMethod = "POST"

                //HTTP 메시지 헤더
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("Bearer \(token!)", forHTTPHeaderField: "Authorization")

                //URLSession 객체를 통해 전송, 응답값 처리
                let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
                    if let e = error{
                        NSLog("An error has occured: \(e.localizedDescription)")
                        return
                    }
                }
                task.resume()
            }
        }else {
            likeBtn.configuration?.image = UIImage(systemName: "heart")
            likeBtn.tag = 0
            
            do{
                guard let url =  URL(string: "\(Network.url)/likes/\(productId)/count") else { return }

                //URLRequest 객체를 정의
                var request = URLRequest(url: url)
                request.httpMethod = "DELETE"

                //HTTP 메시지 헤더
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("Bearer \(token!)", forHTTPHeaderField: "Authorization")

                //URLSession 객체를 통해 전송, 응답값 처리
                let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                    if let e = error{
                        NSLog("An error has occured: \(e.localizedDescription)")
                        return
                    }
                }
                task.resume()
            }
        }
    }
}
