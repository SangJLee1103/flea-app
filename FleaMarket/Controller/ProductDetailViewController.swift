//
//  ProductDetailViewController.swift
//  FleaMarket
//
//  Created by 이상준 on 2022/06/17.
//

import Foundation
import UIKit

class ProductDetailViewController: UIViewController, UIScrollViewDelegate{
    
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var itemScrollView: UIScrollView!
    @IBOutlet var itemPrice: UILabel!
    @IBOutlet var itemName: UILabel!
    @IBOutlet var itemDesc: UITextView!
    
    var productId = 0
    let token = Keychain.read(key: "accessToken")
    var images = [UIImage]()
    var imageViews = [UIImageView]()
    var imageCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        itemScrollView.delegate = self
        productDetailAPI()
    }
    
    
    func productDetailAPI() {
        guard let url =  URL(string: "http://localhost:3000/product/\(productId)") else { return }
    
        //URLRequest 객체를 정의
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        //HTTP 메시지 헤더
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token!)", forHTTPHeaderField: "Authorization")
        
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
                    let data = jsonObject["data"] as! NSDictionary
                    
                    let imgParse = (data["img"] as? String)!.split(separator:",")
                    
                    for i in 0..<imgParse.count {
                        
                        self.images.append(UIImage(data: try! Data(contentsOf: URL(string: "http://localhost:3000/\(imgParse[i])")!))!)
                        
                        
                        let imageView = UIImageView()
                        let xPos = self.view.frame.width * CGFloat(i)
                        imageView.frame = CGRect(x: xPos, y: 0, width: self.itemScrollView.bounds.width, height: self.itemScrollView.bounds.height)
                        
                        imageView.image = self.images[i]
                        self.itemScrollView.addSubview(imageView)
                        self.itemScrollView.contentSize.width = imageView.frame.width * CGFloat(i + 1)
                    }
                    self.pageControl.numberOfPages = imgParse.count
                    self.itemPrice.text = "₩ \(String((data["selling_price"] as? Int)!))"
                    self.itemName.text = data["name"] as? String
                    self.itemDesc.text = data["description"] as? String
                } catch let e as NSError {
                    print("An error has occured while parsing JSONObject: \(e.localizedDescription)")
                }
            }
        }
        task.resume()
    }
    
    func setPageControlSelectedPage(currentPage:Int) {
            pageControl.currentPage = currentPage
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
          let value = itemScrollView.contentOffset.x/itemScrollView.frame.size.width
          setPageControlSelectedPage(currentPage: Int(round(value)))
    }
    
}
