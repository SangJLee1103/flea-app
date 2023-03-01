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
    var products = [ProductModel]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        self.navigationItem.title = "판매목록"
    }
    
    
    // 상품 수정 페이지로 이동하는 함수
    func moveModifyViewController(_ row: ProductModel) {
        guard let productModifyVC = self.storyboard?.instantiateViewController(withIdentifier: "ProductModifyViewController") as? ProductModifyViewController else { return }
        //        productModifyVC.productInfo = row
        productModifyVC.product = row
        self.navigationController?.pushViewController(productModifyVC, animated: true)
    }
    
    // 상품 삭제 함수
    func deleteProduct(productId: Int) {
        ProductService.deleteProduct(productId: productId) { [weak self] response in
            switch response {
            case .success((let result, let status)):
                if status == 200 {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Flea Market", message: result.message[0].msg, preferredStyle: .alert)
                        let action = UIAlertAction(title: "확인", style: .default, handler: nil)
                        alert.addAction(action)
                        self?.present(alert, animated: true, completion: nil)
                    }
                }
            case.failure(_):
                print("error")
            }
        }
    }
    
    // MARK: - 테이블 뷰가 생성해야 할 행의 개수를 반환하는 메소드
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    // MARK: -  각 행이 화면에 표현해야 할 내용을 구성하는 메소드
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell") as! ItemCell
        cell.viewModel = ProductViewModel(product: products[indexPath.row])
        return cell
    }
    
    
    // MARK: - 테이블 뷰 셀 스와이핑 이벤트
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let row = self.products[indexPath.row]
        
        let modify = UIContextualAction(style: .normal, title: "Modify") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            self.moveModifyViewController(row)
            success(true)
        }
        modify.backgroundColor = .systemGray
        
        
        let delete = UIContextualAction(style: .normal, title: "Delete") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            let product = self.products[indexPath.row]
            self.deleteProduct(productId: product.id)
            self.products.remove(at: indexPath.row)
            
            DispatchQueue.main.async {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            success(true)
        }
        delete.backgroundColor = .systemRed
        
        //actions배열 인덱스 0이 오른쪽에 붙어서 나옴
        return UISwipeActionsConfiguration(actions:[delete, modify])
    }
    
    // MARK: - 테이블 뷰 셀 클릭시 상품 상세페이지로
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "ProductDetailViewController") as? ProductDetailViewController else { return }
        nextVC.productId = self.products[indexPath.row].id
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
}
