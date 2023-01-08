//
//  MainViewController.swift
//  FleaMarket
//
//  Created by 이상준 on 2022/04/19.
//

import UIKit
import Foundation

class MainViewController: UIViewController {
    
    @IBOutlet var boardCollectionView: UICollectionView!
    
    let token = Keychain.read(key: "accessToken")
    let fleamarket = ["flea1.png", "flea2.png"]
    var boardId: Int? = 0
    
    private var boards = [BoardModel]() {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.boardCollectionView.reloadData()
            }
        }
    }
    
    var board: BoardModel?
    
    override func viewDidLoad() {
        boardCollectionView.dataSource = self
        boardCollectionView.delegate = self
        initRefresh()
        fetchBoards()
    }
    

    func fetchBoards() {
        BoardService.fetchBoards { [weak self] response in
            switch response {
            case.success(let result):
                self?.boards = result.data
                DispatchQueue.main.async {
                    self?.boardCollectionView.refreshControl?.endRefreshing()
                }
            case.failure(_):
                print("Error")
            }
        }
    }
    
    //새로고침
    func initRefresh(){
        let refresh = UIRefreshControl()
        refresh.tintColor = #colorLiteral(red: 1, green: 0.8705882353, blue: 0.2392156863, alpha: 1)
        refresh.addTarget(self, action: #selector(updateUI), for: .valueChanged)
        boardCollectionView.refreshControl = refresh
    }
    
    @objc func updateUI(){
        boards.removeAll()
        fetchBoards()
    }
}

// MARK: 데이터 소스 설정: 데이터 관련된 것들
extension MainViewController: UICollectionViewDataSource {
    
    // 각 섹션에 들어가는 아이템 갯수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return board == nil ? boards.count : 1
    }
    
    //각 컬렉션 뷰 셀에 대한 설정
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainBoardCell", for: indexPath) as! MainBoardCell
        
        if let board = board {
            cell.viewModel = BoardViewModel(board: board)
        } else {
            cell.viewModel = BoardViewModel(board: boards[indexPath.row])
        }
        return cell
    }
    
    // 셀 클릭 시 이동
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //게시글 아이디
        let id = boards[indexPath.row].id
        let boardName = boards[indexPath.row].topic
        //게시글 아이디 전달 및 게시글페이지로 이동
        guard let boardElement = self.storyboard?.instantiateViewController(withIdentifier: "boardElement") as? ProductPostViewController else { return }
        boardElement.boardId = id
        boardElement.boardName = boardName
        self.navigationController?.pushViewController(boardElement, animated: true)
    }
}

// MARK: 컬렉션 뷰 델리게이트 - 액션과 관련된 것들
extension MainViewController: UICollectionViewDelegate {
    
}
