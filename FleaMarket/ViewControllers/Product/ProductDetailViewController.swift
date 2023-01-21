//
//  ProductDetailViewController.swift
//  FleaMarket
//
//  Created by 이상준 on 2022/06/17.
//

import SDWebImage
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
    
    var viewModel: ProductViewModel? {
        didSet { 
            DispatchQueue.main.async { 
                self.configure()
            }
        }
    }
    
    var productId = 0
    let token = Keychain.read(key: "accessToken")
    var imageCount = 0
    var boardName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        itemScrollView.delegate = self
        fetchProduct()
    }
    
    
    func fetchProduct() {
        ProductService.fetchProduct(productId: productId) { [weak self] response in
            switch response {
            case.success(let result):
                self?.viewModel = ProductViewModel(product: result.data)
            case.failure(_):
                print("Error")
            }
        }
    }
    
    func configure() {
        guard let viewModel = viewModel else { return }
        guard let imgParse = viewModel.imgArray else { return }

        for i in 0..<imgParse.count {
            let imageView = UIImageView()
            let xPos = self.view.frame.width * CGFloat(i)

            imageView.contentMode = .scaleToFill
            imageView.frame = CGRect(x: xPos, y: 0, width: self.itemScrollView.bounds.width, height: self.itemScrollView.bounds.height - 90)
            imageView.sd_setImage(with: URL(string: "\(Network.url)/\(imgParse[i])"))

            self.itemScrollView.addSubview(imageView)
            self.itemScrollView.contentSize.width = imageView.frame.width * CGFloat(i + 1)
        }
        self.pageControl.numberOfPages = imgParse.count
        self.itemPrice.text = viewModel.sellingPrice
        self.itemName.text = viewModel.name
        self.itemDesc.text = viewModel.description
        self.topic.text = viewModel.boardTitle
        self.navigationItem.title = viewModel.start
        self.likeCount.text = "\(viewModel.likesCnt)개"
    }
    
    func setPageControlSelectedPage(currentPage:Int) {
        pageControl.currentPage = currentPage
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let value = itemScrollView.contentOffset.x/itemScrollView.frame.size.width
        setPageControlSelectedPage(currentPage: Int(round(value)))
    }
}
