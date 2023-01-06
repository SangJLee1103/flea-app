//
//  BoardViewModel.swift
//  FleaMarket
//
//  Created by 이상준 on 2023/01/06.
//

import UIKit

struct BoardViewModel {
    var board: BoardModel
    
    var id: Int { return board.id }
    var topic: String { return board.topic }
    var date: String { return board.start }
    var place: String { return board.place }
    var imageUrl: URL? { return URL(string: "\(Network.url)/\(board.thumbnail)") }
    
    
    init(board: BoardModel) {
        self.board = board
    }
}
