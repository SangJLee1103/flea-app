//
//  MyPageViewController.swift
//  FleaMarket
//
//  Created by 이상준 on 2022/04/19.
//

import UIKit


class MyPageViewController: UIViewController {
    
    var activityList = ["나의 게시글", "나의 상품 게시물", "나의 관심 목록"]
    var imageList = ["square.and.pencil", "cart.fill", "suit.heart.fill"]
    let token = Keychain.read(key: "accessToken")
    
    @IBOutlet var activityView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityView.dataSource = self
        activityView.delegate = self
    }
}

extension MyPageViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activityList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityCell", for: indexPath) as! ActivityCell
        cell.activityImage.image = UIImage(systemName: imageList[indexPath.row])
        cell.activity.text = activityList[indexPath.row]
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectItemAt indexPath: IndexPath) {
        NSLog("선택된 행은 \(indexPath.row) 번째 행입니다.")
    }
    
}


extension MyPageViewController: UITableViewDelegate {
    
    
    
}
