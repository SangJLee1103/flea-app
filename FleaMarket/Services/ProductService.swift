//
//  ProductService.swift
//  FleaMarket
//
//  Created by 이상준 on 2023/01/07.
//

import Foundation

struct ProductService {
    
    // MARK: - 상품 등록 API 호출 로직
    static func postProduct(name: String, sellingPrice: String, costPrice: String, description: String, boardId: Int, createdAt: String, selectedData: [Data], completion: @escaping(Result<(ResponseMsgArr, Int), Error>) -> Void) {
        
        guard let token = Keychain.read(key: "accessToken") else { return }
        
        do {
            guard let url = URL(string: "\(Network.url)/product/\(boardId)/register") else {
                print("Error: cannot create URL")
                return
            }
            
            let parameters = [
                "name" : name,
                "selling_price" : sellingPrice,
                "cost_price" : costPrice,
                "description" : description,
                "board_id" : boardId,
                "created_at" : createdAt
            ] as [String : Any]
            
            // boundary 설정
            let boundary = "Boundary-\(UUID().uuidString)"
            
            var request = URLRequest(url: url)
            let session = URLSession(configuration: .default)
            request.httpMethod = "POST"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            // data
            var uploadData = Data()
            let imgDataKey = "img"
            let boundaryPrefix = "--\(boundary)\r\n"
            
            for (key, value) in parameters {
                uploadData.append(boundaryPrefix.data(using: .utf8)!)
                uploadData.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
                uploadData.append("\(value)\r\n".data(using: .utf8)!)
            }
            
            
            for data in selectedData {
                uploadData.append(boundaryPrefix.data(using: .utf8)!)
                uploadData.append("Content-Disposition: form-data; name=\"\(imgDataKey)\"; filename=\"\("Img").png\"\r\n".data(using: .utf8)!)
                uploadData.append("Content-Type: \("image/png")\r\n\r\n".data(using: .utf8)!)
                uploadData.append(data)
                uploadData.append("\r\n".data(using: .utf8)!)
            }
            uploadData.append("--\(boundary)--".data(using: .utf8)!)
            
            
            let task = session.uploadTask(with: request, from: uploadData) { (data, response, error) in
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
    
    // MARK: - 상품 단건조회 API 호출 로직
    static func fetchProduct(productId: Int, completion: @escaping(Result<Product, Error>) -> Void) {
        
        guard let token = Keychain.read(key: "accessToken") else { return }
        
        do {
            guard let url =  URL(string: "\(Network.url)/product/\(productId)") else { return }
            
            //URLRequest 객체를 정의
            var request = URLRequest(url: url)
            let session = URLSession(configuration: .default)
            request.httpMethod = "GET"
            //HTTP 메시지 헤더
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            //URLSession 객체를 통해 전송, 응답값 처리
            let task = session.dataTask(with: request) { (data, response, error) in
                if let e = error{
                    NSLog("An error has occured: \(e.localizedDescription)")
                    return
                }
                if let safeData = data {
                    do {
                        let result = try JSONDecoder().decode(Product.self, from: safeData)
                        completion(.success(result))
                    } catch {
                        NSLog(error.localizedDescription)
                    }
                }
            }
            task.resume()
        }
    }
    
    
    // MARK: - 상품 전체조회 API 호출 로직
    static func fetchProducts(boardId: Int, completion: @escaping(Result<ProductArray, Error>) -> Void) {
        guard let token = Keychain.read(key: "accessToken") else { return }
        do {
            guard let url =  URL(string: "\(Network.url)/product/\(boardId)/all") else { return }
            //URLRequest 객체를 정의
            var request = URLRequest(url: url)
            let session = URLSession(configuration: .default)
            request.httpMethod = "GET"
            
            //HTTP 메시지 헤더
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            //URLSession 객체를 통해 전송, 응답값 처리
            let task = session.dataTask(with: request) { (data, response, error) in
                if let e = error{
                    NSLog("An error has occured: \(e.localizedDescription)")
                    return
                }
                
                if let safeData = data {
                    do {
                        let result = try JSONDecoder().decode(ProductArray.self, from: safeData)
                        completion(.success(result))
                    } catch {
                        NSLog(error.localizedDescription)
                    }
                }
            }
            task.resume()
        }
    }
    
    // MARK: - 플리마켓 별 상품 Top10 조회 API 호출 로직
    static func fetchTop10(boardId: Int, completion: @escaping(Result<RankArray, Error>) -> Void) {
        
        do {
            guard let url =  URL(string: "\(Network.url)/product/\(boardId)/popular") else { return }
            
            //URLRequest 객체를 정의
            var request = URLRequest(url: url)
            let session = URLSession(configuration: .default)
            request.httpMethod = "GET"
            
            //HTTP 메시지 헤더
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            //URLSession 객체를 통해 전송, 응답값 처리
            let task = session.dataTask(with: request) { (data, response, error) in
                if let e = error{
                    NSLog("An error has occured: \(e.localizedDescription)")
                    return
                }
                
                if let safeData = data {
                    do {
                        let result = try JSONDecoder().decode(RankArray.self, from: safeData)
                        completion(.success(result))
                    } catch {
                        NSLog(error.localizedDescription)
                    }
                }
            }
            task.resume()
        }
    }
    
    // MARK: - 상품 좋아요 API 호출 로직
    static func likeProduct(productId: Int) {
        do {
            guard let token = Keychain.read(key: "accessToken") else { return }
            guard let url =  URL(string: "\(Network.url)/likes/\(productId)/count") else { return }
            
            //URLRequest 객체를 정의
            var request = URLRequest(url: url)
            let session = URLSession(configuration: .default)
            request.httpMethod = "POST"
            
            //HTTP 메시지 헤더
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            //URLSession 객체를 통해 전송, 응답값 처리
            let task = session.dataTask(with: request) {(data, response, error) in
                if let e = error{
                    NSLog("An error has occured: \(e.localizedDescription)")
                    return
                }
            }
            task.resume()
        }
    }
    
    // MARK: - 상품 좋아요 취소 API 호출 로직
    static func unlikeProduct(productId: Int) {
        do {
            guard let token = Keychain.read(key: "accessToken") else { return }
            guard let url =  URL(string: "\(Network.url)/likes/\(productId)/count") else { return }

            //URLRequest 객체를 정의
            var request = URLRequest(url: url)
            let session = URLSession(configuration: .default)
            request.httpMethod = "DELETE"
            //HTTP 메시지 헤더
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

            //URLSession 객체를 통해 전송, 응답값 처리
            let task = session.dataTask(with: request) { (data, response, error) in
                if let e = error{
                    NSLog("An error has occured: \(e.localizedDescription)")
                    return
                }
            }
            task.resume()
        }
    }
}
