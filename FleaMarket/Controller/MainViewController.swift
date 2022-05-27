//
//  MainViewController.swift
//  FleaMarket
//
//  Created by 이상준 on 2022/04/19.
//

import UIKit
import Foundation

class MainViewController: UIViewController {
    
    @IBOutlet var boardCollection: UICollectionView!
    
    let token = Keychain.read(key: "accessToken")
    var startTime: String? = ""
    var data : Array<NSDictionary> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getBoardAll { [weak self] datas in
            self?.data = datas
            DispatchQueue.main.async {
                self?.boardCollection.reloadData()
            }
        }
        
        boardCollection.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        boardCollection.dataSource = self
        boardCollection.delegate = self
        initRefresh()
    }
    
    func getBoardAll(callBack: @escaping ((Array<NSDictionary>) -> Void)) {
        do{
            guard let url =  URL(string: "http://localhost:3000/board/read-all") else { return }
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
    
    //새로고침
    func initRefresh(){
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(updateUI(refresh:)), for: .valueChanged)
        
        if #available(iOS 10.0, *){
            boardCollection.refreshControl = refresh
        }else {
            boardCollection.addSubview(refresh)
        }
    }
    
    @objc func updateUI(refresh: UIRefreshControl){
        refresh.endRefreshing() //refresh 종료
        getBoardAll { [weak self] datas in
            self?.data = datas
            DispatchQueue.main.async {
                self?.boardCollection.reloadData()
            }
        }
        self.boardCollection.reloadData() // 컬렉션 뷰 로드
    }
    
}

    


//// 데이터 소스 설정: 데이터 관련된 것들
extension MainViewController: UICollectionViewDataSource {

    // 각 섹션에 들어가는 아이템 갯수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }

    //각 컬렉션 뷰 셀에 대한 설정
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cellId = String(describing: MainSceneBoardCell.self)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MainSceneBoardCell
        
        let writer: NSDictionary? = self.data[indexPath.item]["User"] as? NSDictionary

        cell.writer.text = writer?["nickname"] as? String

        cell.date.text = self.data[indexPath.item]["start"] as? String

        cell.topic.text = self.data[indexPath.item]["topic"] as? String

        
        cell.contentView.layer.cornerRadius = 8
        cell.contentView.layer.borderWidth = 1
        
        return cell
    }
    
    //클릭
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //게시글 아이디
        guard let id = self.data[indexPath.item]["id"] as? Int else { return }
        //게시글 아이디 전달
        guard let boardElement = self.storyboard?.instantiateViewController(withIdentifier: "boardElement") as? BoardElementVC else { return }
        boardElement.boardId = id
        self.navigationController?.pushViewController(boardElement, animated: true)
    }
}

// 컬렉션 뷰 델리게이트 - 액션과 관련된 것들
extension MainViewController: UICollectionViewDelegate {
    
}
