//
//  MyWriteViewController.swift
//  FleaMarket
//
//  Created by 이상준 on 2022/06/04.
//

import Foundation
import UIKit

class MyWriteViewController: UITableViewController {
    
    let token = Keychain.read(key: "accessToken")
    var boards: NSArray = []
    
    override func viewDidLoad() {
        self.navigationItem.title = "게시글"
        self.dataParsing()
    }
    
    
    lazy var boardList: [BoardModel] = {
        var datalist = [BoardModel]()
        return datalist
    }()
    
    // MARK: - 데이터 파싱 함수
    func dataParsing(){
        for row in boards{
            let r = row as! NSDictionary
            
//            let myBoard = BoardModel()
            
//            myBoard.id = r["id"] as? Int
//            myBoard.imgPath = r["thumbnail"] as? String
//            myBoard.topic = r["topic"] as? String
//            myBoard.date = r["start"] as? String
//            myBoard.place = r["place"] as? String
//            myBoard.description = r["description"] as? String
//            myBoard.writer = r["user_id"] as? String
//
//            self.boardList.append(myBoard)
        }
    }
    
    // MARK: - 이미지를 추출하는 함수
//    func getThumbnailImage(_ index: Int) -> UIImage {
//        let board = self.boardList[index]
//
//        if let savedImage = board.thumbnailImage {
//            return savedImage
//        } else {
//            let url: URL! = URL(string: "\(Network.url)/\(board.imgPath!)")
//            let imageData = try! Data(contentsOf: url)
//            board.thumbnailImage = UIImage(data: imageData)
//
//            return board.thumbnailImage!
//        }
//    }
    
    // MARK: - 게시글 수정 페이지 이동 함수
    func moveModifyViewController(_ row: BoardModel) {
        guard let boardModifyVC = self.storyboard?.instantiateViewController(withIdentifier: "BoardModifyViewController") as? BoardModifyViewController else { return }
        boardModifyVC.boardInfo = row
        self.navigationController?.pushViewController(boardModifyVC, animated: true)
    }
    
    // MARK: - 삭제 API 호출 함수
//    func callDeleteAPI(_ row: BoardModel) {
//
//        guard let url = URL(string: "\(Network.url)/board/\(row.writer!)/\(row.id!)") else { return }
//        var request = URLRequest(url: url)
//        request.httpMethod = "DELETE"
//        //HTTP 메시지 헤더
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue("Bearer \(token!)", forHTTPHeaderField: "Authorization")
//
//        //URLSession 객체를 통해 전송, 응답값 처리
//
//        //URLSession 객체를 통해 전송, 응답값 처리
//        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
//            if let e = error{
//                NSLog("An error has occured: \(e.localizedDescription)")
//                return
//            }
//
//            do {
//                let object = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary
//                guard let jsonObject = object else { return }
//                //response 데이터 획득, utf8인코딩을 통해 string형태로 변환
//                // JSON 결과값을 추출
//                let data = jsonObject["message"] as! String
//                // 서버로부터 응답된 스트링 표시
//                DispatchQueue.main.async {
//                    let alert = UIAlertController(title: "Flea Market", message: data, preferredStyle: .alert)
//                    let action = UIAlertAction(title: "확인", style: .default, handler: nil)
//                    alert.addAction(action)
//                    self.present(alert, animated: true, completion: nil)
//                }
//            }catch let e as NSError {
//                print("An error has occured while parsing JSONObject: \(e.localizedDescription)")
//            }
//        }
//        task.resume()
//    }
    
    // MARK: - 테이블 뷰가 생성해야 할 행의 개수를 반환하는 메소드
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return boardList.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    // MARK: -  각 행이 화면에 표현해야 할 내용을 구성하는 메소드
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let row: BoardModel = self.boardList[indexPath.row]
//        let cell = tableView.dequeueReusableCell(withIdentifier: "boardCell") as! BoardCell
//
//        cell.img.layer.cornerRadius = 5
//        cell.img?.image = self.getThumbnailImage(indexPath.row)
//        cell.topic?.text = row.topic
//        cell.place?.text = "장소: \(row.place!)"
//        cell.date?.text = row.date
//        return cell
//    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let boardId = self.boardList[indexPath.row].id
        guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "boardElement") as? ProductPostViewController else { return }
        nextVC.boardId = boardId
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    // MARK: - 테이블 뷰 스와이핑 버튼(수정, 삭제 기능)
//    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        
//        let row = self.boardList[indexPath.row]
//        let modify = UIContextualAction(style: .normal, title: "Modify") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
//            self.moveModifyViewController(row)
//            success(true)
//        }
//        modify.backgroundColor = .systemGray
//        
//        let delete = UIContextualAction(style: .normal, title: "Delete") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
//            self.callDeleteAPI(row)
//
//            DispatchQueue.main.async {
//                self.boardList.remove(at: indexPath.row)
//                tableView.deleteRows(at: [indexPath], with: .fade)
//            }
//            success(true)
//        }
//        delete.backgroundColor = .systemRed
//
//        //actions배열 인덱스 0이 오른쪽에 붙어서 나옴
//        return UISwipeActionsConfiguration(actions:[delete, modify])
//    }
}
