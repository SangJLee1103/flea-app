//
//  Board.swift
//  FleaMarket
//
//  Created by 이상준 on 2022/06/02.
//

import Foundation
import UIKit

class BoardModel {
    var id: Int? // 게시글 아이디
    var writer: String? // 게시글 작성자
    var topic: String?
    var date: String? // 플리마켓 날짜
    var place: String? // 플리마켓 장소
    var description: String? // 플리마켓 주제
    var imgPath: String? // 이미지 경로
    var thumbnailImage: UIImage? // 이미지
}
