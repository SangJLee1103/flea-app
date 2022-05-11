//
//  BoardElementVC.swift
//  FleaMarket
//
//  Created by 이상준 on 2022/04/30.
//

import UIKit

class BoardElementVC: UIViewController {
    
    var boardId: Int?
    let token = Keychain.read(key: "accessToken")
    var image:[String] = ["shirt", "shirt2"]
    var data : Array<NSDictionary> = []
    
    @IBOutlet var lankingView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getTopLanking { [weak self] datas in
            self?.data = datas
            DispatchQueue.main.async {
                self?.lankingView.reloadData()
            }
        }
        lankingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        lankingView.dataSource = self
        lankingView.delegate = self
    }
    
    // 상품 Top10 정보 가져오기
    func getTopLanking(callBack: @escaping ((Array<NSDictionary>) -> Void)){
        do{
            guard let url =  URL(string: "http://localhost:3000/product/\(boardId!)/popular") else { return }
        
            //URLRequest 객체를 정의
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            //HTTP 메시지 헤더
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(token!)", forHTTPHeaderField: "Authorization")
            
            //URLSession 객체를 통해 전송, 응답값 처리
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let e = error{
                    NSLog("An error has occured: \(e.localizedDescription)")
                    return
                }
                // 서버로부터 응답된 스트링 표시
                do {
                    let object = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary
                    guard let jsonObject = object else { return }
                    //response 데이터 획득, utf8인코딩을 통해 string형태로 변환
                    // JSON 결과값을 추출
                    guard let data = jsonObject["data"] as? Array<NSDictionary> else { return  print("") }
                    callBack(data)
                } catch let e as NSError {
                    print("An error has occured while parsing JSONObject: \(e.localizedDescription)")
                }
            }
            task.resume()
        }
    }
    
    func getLankImage(){
        var imgPath: Array? = []
        for i in 0 ..< data.count {
            imgPath?.append(data[i]["img"] as Any)
        }
        print(imgPath)
//        do{
//            guard let url =  URL(string: "http://localhost:3000/product/\(boardId!)/popular") else { return }
//
//            //URLRequest 객체를 정의
//            var request = URLRequest(url: url)
//            request.httpMethod = "GET"
//
//            //HTTP 메시지 헤더
//            //URLSession 객체를 통해 전송, 응답값 처리
//            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
//                if let e = error{
//                    NSLog("An error has occured: \(e.localizedDescription)")
//                    return
//                }
//                // 서버로부터 응답된 스트링 표시
//                do {
//                    let object = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary
//                    guard let jsonObject = object else { return }
//                    //response 데이터 획득, utf8인코딩을 통해 string형태로 변환
//                    // JSON 결과값을 추출
//                    guard let data = jsonObject["data"] as? Array<NSDictionary> else { return  print("") }
//                } catch let e as NSError {
//                    print("An error has occured while parsing JSONObject: \(e.localizedDescription)")
//                }
//            }
//            task.resume()
//        }
    }
}

//데이터 소스 설정 - 데이터 관련
extension BoardElementVC: UICollectionViewDataSource {

    //아이템 갯수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }

    //각 컬렉션뷰 셀에 대한 설정
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellId = String(describing: TopLankingCell.self)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! TopLankingCell
        
        cell.productImg.image = UIImage(named: image[indexPath.row])
        cell.sellerName.text = self.data[indexPath.item]["user_id"] as? String
        let price = self.data[indexPath.item]["selling_price"] as! Int
        cell.sellingPrice.text = String (price) + "원"
        getLankImage()
        return cell
    }

}


//컬렉션 뷰 델리게이트 - 액션 관련
extension BoardElementVC: UICollectionViewDelegate {

}
