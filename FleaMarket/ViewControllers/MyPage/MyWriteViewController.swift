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
    
    var boards = [BoardModel]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        self.navigationItem.title = "게시글"
    }

    
    // MARK: - 게시글 수정 페이지 이동 함수
    func moveModifyViewController(_ row: BoardModel) {
        guard let boardModifyVC = self.storyboard?.instantiateViewController(withIdentifier: "BoardModifyViewController") as? BoardModifyViewController else { return }
        boardModifyVC.boardInfo = row
        self.navigationController?.pushViewController(boardModifyVC, animated: true)
    }
    
    // MARK: - 삭제 API 호출 함수
    func deleteBoard(_ board: BoardModel) {
        BoardService.deleteBoard(board: board) { [weak self] response in
            switch response {
            case .success(let result):
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Flea Market", message: result.message[0].msg, preferredStyle: .alert)
                    let action = UIAlertAction(title: "확인", style: .default, handler: nil)
                    alert.addAction(action)
                    self?.present(alert, animated: true, completion: nil)
                }
            case .failure(_):
                print("Error")
            }
        }
    }
    
    // MARK: - 테이블 뷰가 생성해야 할 행의 개수를 반환하는 메소드
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return boards.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    // MARK: -  각 행이 화면에 표현해야 할 내용을 구성하는 메소드
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "boardCell") as! BoardCell
        cell.viewModel = BoardViewModel(board: boards[indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let boardId = self.boards[indexPath.row].id
        guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "boardElement") as? ProductPostViewController else { return }
        nextVC.boardId = boardId
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    // MARK: - 테이블 뷰 스와이핑 버튼(수정, 삭제 기능)
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let row = self.boards[indexPath.row]
        let modify = UIContextualAction(style: .normal, title: "Modify") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            self.moveModifyViewController(row)
            success(true)
        }
        modify.backgroundColor = .systemGray
        
        let delete = UIContextualAction(style: .normal, title: "Delete") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            self.deleteBoard(row)
            DispatchQueue.main.async {
                self.boards.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            print(self.boards)
            success(true)
        }
        delete.backgroundColor = .systemRed

        //actions배열 인덱스 0이 오른쪽에 붙어서 나옴
        return UISwipeActionsConfiguration(actions:[delete, modify])
    }
}
