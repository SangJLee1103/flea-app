//
//  BoardElementVC.swift
//  FleaMarket
//
//  Created by 이상준 on 2022/04/30.
//

import UIKit
import Foundation
import BSImagePicker

class ProductPostViewController: UIViewController {
    
    var boardId: Int?
    let token = Keychain.read(key: "accessToken")
    
    // 상품 랭킹 컬렉션 뷰
    @IBOutlet var rankingView: UICollectionView!
    // 전체 상품 컬렉션 뷰
    @IBOutlet var productView: UICollectionView!
    @IBOutlet var productNumber: UILabel!
    
    
    // 랭킹 데이터 리스트
    lazy var rankList: [ProductRankingModel] = {
        var datalist = [ProductRankingModel]()
        return datalist
    }()
    
    //상품 데이터 리스트
    lazy var productList: [ProductModel] = {
        var datalist = [ProductModel]()
        return datalist
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "상품"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(goProductRegisterVC))
        
        
        self.getTopRanking {
            DispatchQueue.main.async {
                self.rankingView.reloadData()
            }
        }
        
        self.getProduct {
            DispatchQueue.main.async {
                self.productView.reloadData()
            }
        }
        
        rankingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        rankingView.dataSource = self
        
        productView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        productView.dataSource = self
        
        productView.collectionViewLayout = createCompositional()
        
    }

    // 상품 등록 페이지 이동 함수
    @objc func goProductRegisterVC(){
        guard let productRegister = self.storyboard?.instantiateViewController(withIdentifier: "productRegister") as? ProductRegistrationViewController else { return }
        productRegister.boardId = boardId
        self.navigationController?.pushViewController(productRegister, animated: true)
    }
    
    func popView(){
        self.navigationController?.popViewController(animated: true)
    }
    
    
    // 상품 Top10 정보 가져오기
    func getTopRanking(callBack: @escaping () -> Void) {
            guard let url =  URL(string: "http://172.30.1.63:3000/product/\(boardId!)/popular") else { return }
        
            //URLRequest 객체를 정의
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            //HTTP 메시지 헤더
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
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
                    let data = jsonObject["data"] as! NSArray
                    
                    for row in data {
                        let r = row as! NSDictionary
                        let rankVO = ProductRankingModel()
                        
                        rankVO.id = r["product_id"] as? Int
                        rankVO.price = r["selling_price"] as? Int
                        rankVO.sellerName = r["nickname"] as? String
                        rankVO.productImg = r["img"] as? String
                        
                        self.rankList.append(rankVO)
                        callBack()
                    }
                } catch let e as NSError {
                    print("An error has occured while parsing JSONObject: \(e.localizedDescription)")
                }
            }
            task.resume()
    }
    
    // 전체 상품 조회 API 호출 함수
    func getProduct(callBack: @escaping () -> Void){
        do{
            guard let url =  URL(string: "http://172.30.1.63:3000/product/\(boardId!)/all") else { return }
        
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
                do {
                    let object = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary
                    guard let jsonObject = object else { return }
                   
                    let data = jsonObject["data"] as! NSArray
                    
                    for row in data {
                        let r = row as! NSDictionary
                        let productVO = ProductModel()
                        
                        productVO.id = r["id"] as? Int
                        productVO.productName = r["name"] as? String
                        productVO.sellingPrice = r["selling_price"] as? Int
                        productVO.costPrice = r["cost_price"] as? Int
                        productVO.description = r["description"] as? String
                        productVO.imgPath = r["img"] as? String
                        
                        let seller = r["User"] as! NSDictionary
                        productVO.sellerName = seller["nickname"] as? String
        
                        productVO.like =  r["Likes"] as? NSArray
                        
                        self.productList.append(productVO)
                        callBack()
                    }
                } catch let e as NSError {
                    print("An error has occured while parsing JSONObject: \(e.localizedDescription)")
                }
            }
            task.resume()
        }
    }
}



// 컴포지셔널 레이아웃 관련
extension ProductPostViewController {
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
extension ProductPostViewController: UICollectionViewDataSource {

    //Top10 컬렉션 뷰 부분
    //아이템 갯수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == rankingView {
            return self.rankList.count
        }else if collectionView == productView {
            return self.productList.count
        }
        return 0
    }
    
    //각 컬렉션뷰 셀에 대한 설정
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // top 10 뷰
        if collectionView == rankingView {
            let cellId = String(describing: TopRankingCell.self)
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! TopRankingCell
            
            cell.contentView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            cell.rankingLbl.text = "\(indexPath.row + 1)위"
            
            // top 10 상품 이미지 출력 부분
            
            let row = self.rankList[indexPath.row]
            let imgParse = row.productImg!.split(separator:",")
            
            cell.productImg?.image = UIImage(data: try! Data(contentsOf: URL(string: "http://172.30.1.63:3000/\(imgParse[0])")!))
            cell.sellerName?.text = row.sellerName
            cell.sellingPrice?.text = String (row.price!) + "원"
            
            return cell
        } else if collectionView == productView{
            if productList.count > 0 {
                productNumber.text = "총 \(productList.count)건"
            }
    
            let cellId = String(describing: ProductCell.self)
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ProductCell
            
            let row = self.productList[indexPath.row]
            
            cell.productId = row.id! // 상품 ID
            let imgParse = row.imgPath!.split(separator:",")
            
            cell.img?.image = UIImage(data: try! Data(contentsOf: URL(string: "http://172.30.1.63:3000/\(imgParse[0])")!))
            cell.sellerName?.text = row.sellerName
            cell.name?.text = row.productName
            cell.sellingPrice?.text = String(row.sellingPrice!) + "원"
            
            let like = row.like
            if((like?.count) != 0){ // LIKES 데이터가 있으면
                cell.likeBtn?.tag = 1
            }else {
                cell.likeBtn?.tag = 0
            }
            cell.likeUI()
            
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView ==  rankingView {
            let row = self.rankList[indexPath.row]
            let id = row.id
            
            guard let productDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "ProductDetailViewController") as? ProductDetailViewController else { return }
            productDetailVC.productId = id!
            self.navigationController?.pushViewController(productDetailVC, animated: true)
            
        }else if collectionView == productView{
            let row = self.productList[indexPath.row]
            let id = row.id
            
            guard let productDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "ProductDetailViewController") as? ProductDetailViewController else { return }
            productDetailVC.productId = id!
            self.navigationController?.pushViewController(productDetailVC, animated: true)
        }
    }
}
