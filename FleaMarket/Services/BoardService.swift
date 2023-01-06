//
//  BoardService.swift
//  FleaMarket
//
//  Created by 이상준 on 2023/01/05.
//

import UIKit

struct BoardService {
    
    // MARK: - 게시글 작성 API 호출 로직
    static func writeBoard(topic: String, place: String, start: String, description: String, photo: Data?, completion: @escaping(Result<(ResponseMsgArr, Int), Error>) -> Void) {
        guard let token = Keychain.read(key: "accessToken") else { return }
        do {
            guard let url = URL(string: "\(Network.url)/board/write") else {
                print("Cannot create URL!")
                return
            }
            
            //Json 객체로 전송할 딕셔너리
            let parameters = [
                "topic" : topic,
                "place" : place,
                "start" : start,
                "description" : description
            ] as [String : Any]
            
            var uploadData = Data()
            let boundary = "Boundary-\(UUID().uuidString)"
            
            var request = URLRequest(url: url)
            let session = URLSession(configuration: .default)
            request.httpMethod = "POST"
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            
            let imgDataKey = "img"
            let boundaryPrefix = "--\(boundary)\r\n"
            
            for (key, value) in parameters {
                uploadData.append(boundaryPrefix.data(using: .utf8)!)
                uploadData.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
                uploadData.append("\(value)\r\n".data(using: .utf8)!)
            }
            
            uploadData.append(boundaryPrefix.data(using: .utf8)!)
            uploadData.append("Content-Disposition: form-data; name=\"\(imgDataKey)\"; filename=\"\("Img").png\"\r\n".data(using: .utf8)!)
            uploadData.append("Content-Type: \("image/png")\r\n\r\n".data(using: .utf8)!)
            uploadData.append(photo!)
            uploadData.append("\r\n".data(using: .utf8)!)
            uploadData.append("--\(boundary)--".data(using: .utf8)!)
            
            //URLSession 객체를 통해 전송, 응답값 처리
            let task = session.uploadTask(with: request, from: uploadData) { (data, response, error) in
                    // 서버로부터 응답된 스트링 표시
                let status = (response as? HTTPURLResponse)?.statusCode ?? 0
                
                if let e = error{
                    NSLog("An error has occured: \(e.localizedDescription)")
                    return
                }
                
                if let safeData = data {
                    do {
                        let result = try JSONDecoder().decode(ResponseMsgArr.self, from: safeData)
                        completion(.success((result, status)))
                    } catch {
                        NSLog(error.localizedDescription)
                    }
                }
            }
            task.resume()
        }
    }
    
    // MARK: - 게시글 전체 조회 API 호출
    static func fetchBoards(completion: @escaping(Result<BoardArray, Error>) -> Void) {
        guard let token = Keychain.read(key: "accessToken") else { return }
        do {
            guard let url =  URL(string: "\(Network.url)/board/read-all") else { return }
            //URLRequest 객체를 정의
            var request = URLRequest(url: url)
            let session = URLSession(configuration: .default)
            request.httpMethod = "GET"
            
            
            //HTTP 메시지 헤더
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                
            let task = session.dataTask(with: request) { data, response, error in
                if let e = error{
                    NSLog("An error has occured: \(e.localizedDescription)")
                    return
                }
                
                if let safeData = data {
                    do {
                        let result = try JSONDecoder().decode(BoardArray.self, from: safeData)
                        completion(.success(result))
                    } catch {
                        NSLog(error.localizedDescription)
                    }
                }
            }
            task.resume()
        }
    }
}
