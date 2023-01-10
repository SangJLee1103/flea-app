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
    
//    let userInfoVO = UserInfoModel()
    
    lazy var list: [UserInfoModel] = {
        var datalist = [UserInfoModel]()
        return datalist
    }()
    
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
    
    override func viewDidAppear(_ animated: Bool) {
//        self.callUserInfoAPI()
    }
    
    @objc func moveEditPersonalInfoVC(sender : UITapGestureRecognizer) {
        // Do what you want
        guard let editPersonalInfoVC = self.storyboard?.instantiateViewController(withIdentifier: "EditPersonalInfoViewController") as? EditPersonalInfoViewController else { return }
//        editPersonalInfoVC.email = self.userInfoVO.email
//        editPersonalInfoVC.phoneNumber = self.userInfoVO.phoneNumber
//        editPersonalInfoVC.nickName = self.userInfoVO.nickname
//
        self.navigationController?.pushViewController(editPersonalInfoVC, animated: true)
    }
    
    
    // 회원 정보 가져옴(회원 개인정보, 게시글, 상품)
//    func callUserInfoAPI() {
//        guard let url =  URL(string: "\(Network.url)/member/info") else { return }
//        //URLRequest 객체를 정의
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//
//        //HTTP 메시지 헤더
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue("Bearer \(token!)", forHTTPHeaderField: "Authorization")
//
//        //URLSession 객체를 통해 전송, 응답값 처리
//        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
//            if let e = error{
//                NSLog("An error has occured: \(e.localizedDescription)")
//                return
//            }
//            // 서버로부터 응답된 스트링 표시
//            DispatchQueue.main.async {
//                do {
//                    let object = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
//                    //guard let jsonObject = object else { return }
//                    //response 데이터 획득, utf8인코딩을 통해 string형태로 변환
//                    // JSON 결과값을 추출
//                    let data = object["list"] as? Array<NSDictionary>
//
//                    self.userInfoVO.email = data?[0]["id"] as? String
//                    self.userInfoVO.password = data?[0]["password"] as? String
//                    self.userInfoVO.phoneNumber = data?[0]["phone"] as? String
//                    self.userInfoVO.nickname = data?[0]["nickname"] as? String
//                    self.userInfoVO.boards = data?[0]["Boards"] as? NSArray
//                    self.userInfoVO.products = data?[0]["Products"] as? NSArray
//                    self.userInfoVO.likes = data?[0]["Likes"] as? Array<NSDictionary>
//
//                    self.list.append(self.userInfoVO)
//
//                    if let nickname = self.userInfoVO.nickname {
//                        self.nickname.text = "닉네임: \(nickname)"
//                    }
//
//                    if let phone = self.userInfoVO.phoneNumber {
//                        self.phone.text = "휴대폰 번호: \(phone.pretty())"
//                    }
//
//                    self.phone.text = "휴대폰 번호: \(self.userInfoVO.phoneNumber!.pretty())"
//
//                } catch let e as NSError {
//                    print("An error has occured while parsing JSONObject: \(e.localizedDescription)")
//                }
//            }
//        }
//        task.resume()
    }
    
//    @IBAction func logout(_ sender: UIButton) {
//        let appDelegate = AppDelegate()
//        if Keychain.read(key: "accessToken") != nil {
//            let alert = UIAlertController(title: "FleaMarket", message: "정말 로그아웃 하시겠습니까?", preferredStyle: .alert)
//            let alertLogoutAction = UIAlertAction(title: "로그아웃", style: .default) {_ in
//                appDelegate.resetApp()
//            }
//            let alertCanceAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
//            alert.addAction(alertLogoutAction)
//            alert.addAction(alertCanceAction)
//
//            self.present(alert, animated: false)
//        } else {
//            return
//        }
//    }
//}

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
        
//        switch indexPath.row{
//        case 0:
//            guard let myWriteVC = self.storyboard?.instantiateViewController(withIdentifier: "MyWriteViewController") as? MyWriteViewController else { return }
//            myWriteVC.boards = self.userInfoVO.boards!
//            self.navigationController?.pushViewController(myWriteVC, animated: true)
//            
//        case 1:
//            guard let myuploadItemVC = self.storyboard?.instantiateViewController(withIdentifier: "MyProductViewController") as? MyProductViewController else { return }
//            myuploadItemVC.item = self.userInfoVO.products!
//            self.navigationController?.pushViewController(myuploadItemVC, animated: true)
//            
//        case 2:
//            guard let myLikeVC = self.storyboard?.instantiateViewController(withIdentifier:    "MyLikeItemViewController") as? MyLikeViewController else { return }
//            myLikeVC.likeItem = self.userInfoVO.likes!
//            self.navigationController?.pushViewController(myLikeVC, animated: true)
//            
//        default:
//            return
//        }
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
