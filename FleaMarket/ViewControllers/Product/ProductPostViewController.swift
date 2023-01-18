//
//  BoardElementVC.swift
//  FleaMarket
//
//  Created by 이상준 on 2022/04/30.
//

import UIKit
import Foundation
import BSImagePicker
import SnapKit

class ProductPostViewController: UIViewController {
    
    let token = Keychain.read(key: "accessToken")
    var boardId: Int? = 0
    var boardName: String? = ""
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var contentView: UIView!
    @IBOutlet var rankingLbl: UILabel!
    // 상품 랭킹 컬렉션 뷰
    @IBOutlet var rankingView: UICollectionView!
    // 전체 상품 컬렉션 뷰
    @IBOutlet var productView: UICollectionView!
    @IBOutlet var productNumber: UILabel!
    @IBOutlet var llineLbl: UILabel!
    
    // top 10
    private var rankList = [ProductRankingModel]() {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.rankingView.reloadData()
            }
        }
    }
    
    // 전체 상품
    private var productList = [ProductModel]() {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.productView.reloadData()
                self?.updateScrollView()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "상품"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(goProductRegisterVC))
        
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 0.8705882353, blue: 0.2392156863, alpha: 0.8470588235)
        
        scrollView.delegate = self
        
        rankingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        rankingView.dataSource = self
        rankingView.delegate = self
        
        productView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        productView.dataSource = self
        productView.delegate = self
        
        fetchTop10()
        fetchProducts()
        
        rankingView.collectionViewLayout = createCompositionalRankingView()
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
    func fetchTop10() {
        guard let boardId = boardId else { return }
        ProductService.fetchTop10(boardId: boardId) { [weak self] response in
            switch response {
            case .success(let result):
                self?.rankList = result.data
            case .failure(_):
                print("Error")
            }
        }
        
        if self.rankList.count <= 0 {
            DispatchQueue.main.async {
                self.rankingLbl.layer.isHidden = true
            }
        }
    }
    
    // 전체 상품 조회 API 호출 함수
    func fetchProducts(){
        guard let boardId = boardId else { return }
        ProductService.fetchProducts(boardId: boardId) { [weak self] response in
            switch response {
            case .success(let result):
                self?.productList = result.data
            case.failure(_):
                print("Error")
            }
        }
        
        if self.productList.count <= 0 {
            DispatchQueue.main.async {
                self.productNumber.center = CGPoint(x: self.view.frame.size.width / 2, y: self.view.frame.size.height / 2 - 100)
                self.llineLbl.layer.isHidden = true
                // 상품이 없을 경우 상품이 없다는 라벨 가운데로
                self.llineLbl.snp.remakeConstraints {
                    $0.centerX.centerY.equalToSuperview()
                }
            }
        } 
    }
    
    func updateScrollView() {
        let height: CGFloat = 450 + CGFloat(round(Double(productList.count) / 2.0) * 280)
        DispatchQueue.main.async {
            self.contentView.snp.remakeConstraints {
                $0.edges.equalTo(self.scrollView)
                $0.width.equalTo(self.view.frame.width)
                $0.height.equalTo(height)
            }
        }
    }
}

// 컴포지셔널 레이아웃 관련
extension ProductPostViewController {
    fileprivate func createCompositional() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout{
            (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/2), heightDimension: .absolute(279))
            
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: CGFloat(0.0), leading: CGFloat(0.0), bottom: CGFloat(0.0), trailing: CGFloat(0.0))
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: itemSize.heightDimension)
            
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
            return section
        }
        return layout
    }
    
    fileprivate func createCompositionalRankingView() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout{
            (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/2), heightDimension: .absolute(299))
            
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: CGFloat(0.0), leading: CGFloat(0.0), bottom: CGFloat(0.0), trailing: CGFloat(0.0))
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: itemSize.heightDimension)
            
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
            section.orthogonalScrollingBehavior = .groupPaging
            return section
        }
        return layout
    }
}

//데이터 소스 설정 - 데이터 관련
extension ProductPostViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    //Top10 컬렉션 뷰 부분
    //아이템 갯수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == rankingView {
            return rankList.count
        }else if collectionView == productView {
            return productList.count
        }
        return 0
    }
    
    //각 컬렉션뷰 셀에 대한 설정
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // top 10 뷰
        if collectionView == rankingView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TopRankingCell", for: indexPath) as! TopRankingCell
            cell.rankingLbl.text = "\(indexPath.row + 1)위"
            cell.viewModel = RankingViewModel(ranker: rankList[indexPath.row])
            return cell
        } else if collectionView == productView{
            if productList.count > 0 {
                self.productNumber.textAlignment = .left
                productNumber.text = "총 \(productList.count)건"
                productNumber.font = .systemFont(ofSize: 14)
                productNumber.textColor = .black
            }
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! ProductCell
            cell.viewModel = ProductViewModel(product: productList[indexPath.row])
            
            let like = cell.viewModel?.likesCnt
            if(like != 0){ // LIKES 데이터가 있으면
                cell.likeBtn?.tag = 1
            }else {
                cell.likeBtn?.tag = 0
            }
            cell.likeUI()
            
            return cell
        }
        return UICollectionViewCell()
    }
    
    // MARK: - 컬렉션 뷰 셀 선택
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == rankingView {
            let row = self.rankList[indexPath.row]
            let id = row.id
            
            guard let productDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "ProductDetailViewController") as? ProductDetailViewController else { return }
            productDetailVC.productId = id
            productDetailVC.boardName = boardName
            self.navigationController?.pushViewController(productDetailVC, animated: true)
            
        }else if collectionView == productView{
            let row = self.productList[indexPath.row]
            let id = row.id
            
            guard let productDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "ProductDetailViewController") as? ProductDetailViewController else { return }
            productDetailVC.productId = id
            productDetailVC.boardName = boardName
            self.navigationController?.pushViewController(productDetailVC, animated: true)
        }
    }
}

extension ProductPostViewController: UIScrollViewDelegate {
    
}
