//
//  MyPageViewController.swift
//  FleaMarket
//
//  Created by 이상준 on 2022/04/19.
//

import UIKit
import Foundation


class MyPageViewController: UIViewController {
    
    var activityList = ["플리마켓", "판매목록", "관심목록"]
    var imageList = ["square.and.pencil", "cart.fill", "suit.heart.fill"]
    let token = Keychain.read(key: "accessToken")
    
    @IBOutlet var topView: UIView!
    @IBOutlet var activityTableView: UITableView!
    @IBOutlet var nickname: UILabel!
    @IBOutlet var phone: UILabel!
    @IBOutlet var img: UIImageView!
    
    var viewModel: UserInfoViewModel? {
        didSet {
            DispatchQueue.main.async {
                self.configure()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 0.8705882353, blue: 0.2392156863, alpha: 0.8470588235)
        
        activityTableView.dataSource = self
        activityTableView.delegate = self
        activityTableView.isScrollEnabled = false
        
        img.layer.cornerRadius = img.frame.size.width / 2
        img.layer.borderWidth = 0
        img.layer.masksToBounds = true
        
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.moveEditPersonalInfoVC))
        self.topView.addGestureRecognizer(gesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchUser()
    }
    

    
    @objc func moveEditPersonalInfoVC(sender : UITapGestureRecognizer) {
        guard let editPersonalInfoVC = self.storyboard?.instantiateViewController(withIdentifier: "EditPersonalInfoViewController") as? EditPersonalInfoViewController else { return }
        editPersonalInfoVC.email = viewModel?.id
        editPersonalInfoVC.phoneNumber = viewModel?.phone
        editPersonalInfoVC.nickName = viewModel?.nickname

        self.navigationController?.pushViewController(editPersonalInfoVC, animated: true)
    }
    
    func fetchUser() {
        MemberService.fetchUser { [weak self] response in
            switch response {
            case .success(let result):
                self?.viewModel = UserInfoViewModel(userInfo: result.list)
            case .failure(_):
                print("Error")
            }
        }
    }
    
    func configure() {
        self.nickname.text = viewModel?.nickname
        self.phone.text = viewModel?.phone.pretty()
    }
    
    // 로그아웃
    @IBAction func logout(_ sender: UIButton) {
        let appDelegate = AppDelegate()
        if Keychain.read(key: "accessToken") != nil {
            let alert = UIAlertController(title: "FleaMarket", message: "정말 로그아웃 하시겠습니까?", preferredStyle: .alert)
            let alertLogoutAction = UIAlertAction(title: "로그아웃", style: .default) {_ in
                appDelegate.resetApp()
            }
            let alertCanceAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            alert.addAction(alertLogoutAction)
            alert.addAction(alertCanceAction)

            self.present(alert, animated: false)
        } else {
            return
        }
    }
}

extension MyPageViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activityList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MypageCell", for: indexPath) as! MypageCell
        cell.activityImage.image = UIImage(systemName: imageList[indexPath.row])
        cell.activity.text = activityList[indexPath.row]
        
        return cell
    }
}

// 액션 관련
extension MyPageViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row{
        case 0:
            guard let myWriteVC = self.storyboard?.instantiateViewController(withIdentifier: "MyWriteViewController") as? MyWriteViewController else { return }
            myWriteVC.boards = self.viewModel?.boards ?? []
            self.navigationController?.pushViewController(myWriteVC, animated: true)
            
        case 1:
            guard let myuploadItemVC = self.storyboard?.instantiateViewController(withIdentifier: "MyProductViewController") as? MyProductViewController else { return }
            myuploadItemVC.products = self.viewModel?.products ?? []
            self.navigationController?.pushViewController(myuploadItemVC, animated: true)
            
        case 2:
            guard let myLikeVC = self.storyboard?.instantiateViewController(withIdentifier:    "MyLikeItemViewController") as? MyLikeViewController else { return }
            myLikeVC.likeItem = self.viewModel?.likes ?? []
            self.navigationController?.pushViewController(myLikeVC, animated: true)
            
        default:
            return
        }
    }
}

// MARK: 휴대폰 번호 사이사이에 하이픈을 위한 확장
extension String {
    func pretty() -> String {
        let _str = self.replacingOccurrences(of: "-", with: "") // 하이픈 모두 빼준다
        let arr = Array(_str)
        
        if let regex = try? NSRegularExpression(pattern: "([0-9]{3})([0-9]{3,4})([0-9]{4})", options: .caseInsensitive) {
            let modString = regex.stringByReplacingMatches(in: _str, options: [],
                                                           range: NSRange(_str.startIndex..., in: _str),
                                                           withTemplate: "$1-$2-$3")
            return modString
        }
        return self
    }
}
