//
//  BoardElementVC.swift
//  FleaMarket
//
//  Created by 이상준 on 2022/04/30.
//

import UIKit
import Foundation
import BSImagePicker

class BoardElementVC: UIViewController {
    
    var boardId: Int?
    let token = Keychain.read(key: "accessToken")
    var lankData : Array<NSDictionary> = []
    var productData: Array<NSDictionary> = []
    var likeData: Array<NSDictionary> = []
    
    
    // 상품 랭킹 컬렉션 뷰
    @IBOutlet var lankingView: UICollectionView!
    // 전체 상품 컬렉션 뷰
    @IBOutlet var productView: UICollectionView!
    @IBOutlet var productNumber: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "상품"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(goProductRegisterVC))
        
        
        getTopLanking { [weak self] datas in
            self?.lankData = datas
            DispatchQueue.main.async {
                self?.lankingView.reloadData()
            }
        }
        
        getProduct { [weak self] datas in
            self?.productData = datas
            DispatchQueue.main.async {
                self?.productView.reloadData()
            }
        }
        
        lankingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        lankingView.dataSource = self
        lankingView.delegate = self
        
        productView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        productView.dataSource = self
        productView.delegate = self
        
        productView.collectionViewLayout = createCompositional()
        
    }

    // 상품 등록 페이지 이동 함수
    @objc func goProductRegisterVC(){
        
        guard let productRegister = self.storyboard?.instantiateViewController(withIdentifier: "productRegister") as? ProductRegisterVC else { return }
        productRegister.boardId = boardId
        self.navigationController?.pushViewController(productRegister, animated: true)
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
    
    // 전체 상품 조회 API 호출 함수
    func getProduct(callBack: @escaping ((Array<NSDictionary>) -> Void)){
        do{
            guard let url =  URL(string: "http://localhost:3000/product/\(boardId!)/all") else { return }
        
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
                    guard let productData = jsonObject["data"] as? Array<NSDictionary> else { return  print("") }
                    callBack(productData)
                } catch let e as NSError {
                    print("An error has occured while parsing JSONObject: \(e.localizedDescription)")
                }
            }
            task.resume()
        }
    }
}



// 컴포지셔널 레이아웃 관련
extension BoardElementVC {
    fileprivate func createCompositional() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout{
            (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in

            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/2), heightDimension: .absolute(270))
            
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: CGFloat(1.0), leading: CGFloat(1.0), bottom: CGFloat(1.0), trailing: CGFloat(1.0))
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: itemSize.heightDimension)
            
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1)
            return section
        }
        return layout
    }
}



//데이터 소스 설정 - 데이터 관련
extension BoardElementVC: UICollectionViewDataSource {

    //Top10 컬렉션 뷰 부분
    //아이템 갯수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == lankingView {
            return lankData.count
        }else if collectionView == productView {
            return productData.count
        }
        return 0
    }
    
    //각 컬렉션뷰 셀에 대한 설정
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // top 10 뷰
        if collectionView == lankingView {
            let cellId = String(describing: TopLankingCell.self)
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! TopLankingCell
            
            cell.contentView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            cell.lankingLbl.text = "\(indexPath.row + 1)위"
            
            // top 10 상품 이미지 출력 부분
            let lankImage = (lankData[indexPath.row]["img"] as! String).split(separator:",")
            let url: URL! = URL(string: "http://localhost:3000/\(lankImage[0])")
            let imageData = try! Data(contentsOf: url)
            cell.productImg.image = UIImage(data:imageData)
            
            let sellerName = self.lankData[indexPath.row]["nickname"] as! String
            cell.sellerName.text = sellerName
            
            let price = self.lankData[indexPath.row]["selling_price"] as! Int
            cell.sellingPrice.text = String (price) + "원"
            return cell
        } else if collectionView == productView{
            if productData.count > 0 {
                productNumber.text = "총 \(productData.count)건"
            }
    
            let cellId = String(describing: ProductCell.self)
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ProductCell
            
            let id = self.productData[indexPath.row]["id"] as! Int
            cell.productId = id // 상품 ID
            
            let productImg = (productData[indexPath.row]["img"] as! String).split(separator:",")
            let url: URL! = URL(string: "http://localhost:3000/\(productImg[0])")
            let imageData = try! Data(contentsOf: url)
            cell.img.image = UIImage(data:imageData)
          
            
            let sellerName: NSDictionary? = self.productData[indexPath.row]["User"] as? NSDictionary
            cell.sellerName.text = sellerName?["nickname"] as? String
            
            let productName = self.productData[indexPath.row]["name"] as! String
            cell.name.text = productName
            
            let price = self.productData[indexPath.row]["selling_price"] as! Int
            cell.sellingPrice.text = String (price) + "원"
            
            
            let like = self.productData[indexPath.row]["Likes"] as? Array<NSDictionary>
            if((like?.count) != 0){ // LIKES 데이터가 있으면
                cell.likeBtn.tag = 1
            }else {
                cell.likeBtn.tag = 0
            }

            cell.likeUI()
            
            return cell
        }
        return UICollectionViewCell()
    }
}
    
    

//컬렉션 뷰 델리게이트 - 액션 관련
extension BoardElementVC: UICollectionViewDelegate {

}
