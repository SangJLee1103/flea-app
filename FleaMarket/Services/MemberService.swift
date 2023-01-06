//
//  MemberService.swift
//  FleaMarket
//
//  Created by 이상준 on 2022/12/30.
//

import Foundation

struct MemberService {
    
    // MARK: - 로그인 API 호출 로직
    static func login(email: String, password: String, completion: @escaping(Result<LoginResponse, Error>) -> Void) {
        do {
            guard let url = URL(string: "\(Network.url)/member/login") else {
                print("Cannot create URL!")
                return
            }
            
            let loginUser = LoginModel(id: email, password: password)
            let uploadData = try? JSONEncoder().encode(loginUser)
            
            //URLRequest 객체를 정의
            let session = URLSession(configuration: .default)
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            //URLSession 객체를 통해 전송, 응답값 처리
            let task = session.uploadTask(with: request, from: uploadData) { (data, response, error) in
                let status = (response as? HTTPURLResponse)?.statusCode ?? 0
                
                if let e = error{
                    NSLog("An error has occured: \(e.localizedDescription)")
                    return
                }
                // 서버로부터 응답된 스트링 표시
                
                if let safeData = data {
                    do {
                        if status == 200 {
                            let result = try JSONDecoder().decode(LoginResponse.self, from: safeData)
                            completion(.success(result))
                        } else { // 로그인 실패시
                            let result = try JSONDecoder().decode(LoginResponse.self, from: safeData)
                            completion(.success(result))
                        }
                    } catch {
                        NSLog(error.localizedDescription)
                    }
                }
            }
            task.resume()
        }
    }
    
    // MARK: - 회원가입 API 호출 로직
    static func join(email: String, password: String, nickname: String, phone: String, completion: @escaping(Result<(ResponseMsgArr, Int), Error>) -> Void) {
        do {
            guard let url = URL(string: "\(Network.url)/member/join") else {
                print("Cannot create URL!")
                return
            }
            
            let joinUser = JoinModel(id: email, password: password, nickname: nickname, phone: phone)
            let uploadData = try? JSONEncoder().encode(joinUser)
            
            //URLRequest 객체를 정의
            var request = URLRequest(url: url)
            let session = URLSession(configuration: .default)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            
            //URLSession 객체를 통해 전송, 응답값 처리
            let task = session.uploadTask(with: request, from: uploadData) { (data, response, error) in
                let status = (response as? HTTPURLResponse)?.statusCode ?? 0
                
                if let e = error{
                    NSLog("An error has occured: \(e.localizedDescription)")
                    return
                }
                // 서버로부터 응답된 스트링 표시
                
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
    
}

