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
    
    let school = ["school1.png", "school2.png"]
    let church = ["cross1.png", "cross2.png"]
    let fleamarket = ["flea1.png", "flea2.png"]
    

    // lazy 키워드 사용이유
    // 1.미리 생성하지 않고 변수가 참조되는 시점에 맞추어 초기화되므로 메모리 낭비를 줄여줌
    // 2. lazy 키워드를 붙이지 않은 프로퍼티는 다른 프로퍼티를 참조할 수 없기 때문
    lazy var list: [Board] = {
        var datalist = [Board]()
        return datalist
    }()
    
    override func viewDidLoad() {
        boardCollection.dataSource = self
        boardCollection.delegate = self
        
        self.getBoardAll{
            DispatchQueue.main.async { [weak self] in
                self?.boardCollection.reloadData()
            }
        }
       
        self.initRefresh()
    }
    
    func getBoardAll(callback: @escaping () -> Void) {
        list = [] //데이터를 한번 비워줌
        guard let url =  URL(string: "http://localhost:3000/board/read-all") else { return }
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
                    //response 데이터 획득, utf8인코딩을 통해 string형태로 변환
                    // JSON 결과값을 추출
                    let data = jsonObject["data"] as! NSArray
                    
                    for row in data{
                        let r = row as! NSDictionary
                        let boardVO = Board()
                        
                        boardVO.id = r["id"] as? Int
                        boardVO.date = r["start"] as? String
                        boardVO.topic = r["topic"] as? String
                        boardVO.place = r["place"] as? String
                        boardVO.description = r["description"] as? String
                        boardVO.imgPath = r["thumbnail"] as? String
                        let writer = r["User"] as! NSDictionary
                        boardVO.writer = writer["nickname"] as? String
                        self.list.append(boardVO)
                        callback()
                    }
                } catch let e as NSError {
                    print("An error has occured while parsing JSONObject: \(e.localizedDescription)")
                }
            }
            task.resume()
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
        list = [] //데이터를 한번 비워주고 API를 다시 호출
        getBoardAll {
            DispatchQueue.main.async { [weak self] in
                self?.boardCollection.reloadData()
            }
        }
    }
    
    
    func updateAPI(){
        getBoardAll {
            DispatchQueue.main.async { [weak self] in
                self?.boardCollection.reloadData()
            }
        }
        print("writeVC에서 호출됨")
    }
    
}

    
// MARK: 데이터 소스 설정: 데이터 관련된 것들
extension MainViewController: UICollectionViewDataSource {

    // 각 섹션에 들어가는 아이템 갯수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.list.count
    }

    //각 컬렉션 뷰 셀에 대한 설정
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellId = String(describing: MainSceneBoardCell.self)
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MainSceneBoardCell
        
        let row = self.list[indexPath.row]
        
        cell.image.layer.cornerRadius = 10
        
//        guard let imgParse = row.imgPath else {
//            cell.image?.image = UIImage(named: fleamarket[Int.random(in: 0..<2)])
//
//        }
//
//        let url = "http://localhost:3000/\(String(describing: row.imgPath))"
        
        let url: URL! = URL(string: row.imgPath!)
        
        if (url != nil) {
            cell.image?.image = UIImage(data: try! Data(contentsOf: URL(string: "http://localhost:3000/\(String(describing: url!))")!))
        } else {
            cell.image?.image = UIImage(named: fleamarket[Int.random(in: 0..<2)])
        }
        
        cell.topic?.text = row.topic
        cell.date?.text = row.date
        cell.place?.text = "장소:\(String(describing: row.place!))"
        
      
        return cell
    }
    
    // 셀 클릭 시 이동
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //게시글 아이디
        
        let row = self.list[indexPath.row]
        let id = row.id
        //게시글 아이디 전달 및 게시글페이지로 이동
        guard let boardElement = self.storyboard?.instantiateViewController(withIdentifier: "boardElement") as? BoardElementVC else { return }
        boardElement.boardId = id
        self.navigationController?.pushViewController(boardElement, animated: true)
    }
}

// MARK: 컬렉션 뷰 델리게이트 - 액션과 관련된 것들
extension MainViewController: UICollectionViewDelegate {
    
}
