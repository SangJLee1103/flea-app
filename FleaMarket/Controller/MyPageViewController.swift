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
    
    
    @IBOutlet var nickname: UILabel!
    @IBOutlet var phone: UILabel!
    
    lazy var list: [UserInfoResponse] = {
        var datalist = [UserInfoResponse]()
        return datalist
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.callUserInfoAPI()
        activityView.dataSource = self
        activityView.delegate = self
    }
    
    
    // 회원 정보 가져옴(회원 개인정보, 게시글, 상품)
    func callUserInfoAPI(){
        guard let url =  URL(string: "http://localhost:3000/member/info") else { return }
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
                        let data = jsonObject["list"] as? Array<NSDictionary>
                    
                        let userInfoVO = UserInfoResponse()

                        userInfoVO.email = data![0]["id"] as? String
                        userInfoVO.password = data![0]["password"] as? String
                        userInfoVO.phoneNumber = data![0]["phone"] as? String
                        userInfoVO.nickname = data![0]["nickname"] as? String
                        userInfoVO.boards = data![0]["Boards"] as? NSArray
                        userInfoVO.products = data![0]["Products"] as? NSArray
                        
                        self.list.append(userInfoVO)
                    
                        self.nickname.text = "닉네임: \(userInfoVO.nickname!)"
                        self.phone.text = "휴대폰 번호: \(userInfoVO.phoneNumber!)"
                    
                    
                } catch let e as NSError {
                    print("An error has occured while parsing JSONObject: \(e.localizedDescription)")
                }
            }
        }
        task.resume()
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
