//
//  ProductDetailViewController.swift
//  FleaMarket
//
//  Created by 이상준 on 2022/06/17.
//

import Foundation
import UIKit

class ProductDetailViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var itemScrollView: UIScrollView!
    @IBOutlet var itemName: UILabel!
    @IBOutlet var itemPrice: UILabel!
    @IBOutlet var topic: UILabel!
    @IBOutlet var itemDesc: UITextView!
    @IBOutlet var likeCount: UILabel!
    
    
    var productId = 0
    let token = Keychain.read(key: "accessToken")
    var images = [UIImage]()
    var imageCount = 0
    var boardName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        itemScrollView.delegate = self
        productDetailAPI()
        
    }
    
    
    func productDetailAPI() {
        guard let url =  URL(string: "\(Network.url)/product/\(productId)") else { return }
        
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
                        self.images.append(UIImage(data: try! Data(contentsOf: URL(string: "\(Network.url)/\(imgParse[i])")!))!)
                        
                        let imageView = UIImageView()
                        let xPos = self.view.frame.width * CGFloat(i)
                        
                        imageView.contentMode = .scaleToFill
                        imageView.frame = CGRect(x: xPos, y: 0, width: self.itemScrollView.bounds.width, height: self.itemScrollView.bounds.height - 90)
                        imageView.image = self.images[i]
                        
                        self.itemScrollView.addSubview(imageView)
                        self.itemScrollView.contentSize.width = imageView.frame.width * CGFloat(i + 1)
                    }
                    self.pageControl.numberOfPages = imgParse.count
                    
                    let numberFormatter = NumberFormatter()
                    numberFormatter.numberStyle = .decimal
                    
                    guard let price = data["selling_price"] as? Int else {return}
                    let priceDecimal = numberFormatter.string(from: NSNumber(value: price))

                    self.itemPrice.text = "\(priceDecimal ?? "0")원"
                    self.itemName.text = data["name"] as? String
                    self.itemDesc.text = data["description"] as? String
                    
                    guard let topic = data["Board"] as? NSDictionary else { return }
                    self.topic.text = "장소: \(topic["place"] as? String ?? "미정")"
                    
                    guard let startParsing = data["Board"] as? NSDictionary else { return }
                    var start = startParsing["start"] as? String
                    self.navigationItem.title = "\(start?.prefix(12) ?? "")"
                    
                    guard let likeCount = data["Likes"] as? NSArray else { return }
                    self.likeCount.text = "\(likeCount.count)개"
                    
                    
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