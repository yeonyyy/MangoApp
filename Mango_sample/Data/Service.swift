//
//  Service.swift
//  Mango_sample
//
//  Created by rayeon lee on 4/16/24.
//

import RxSwift
import Foundation

enum HTTP: String {
    case get = "GET"
    case post = "POST"
}

enum APIError: LocalizedError {
    case url
    case response
    case statusCode(Int)
    case responseData
    case jsonDecode
}

protocol ServiceProtocol {
    func requestPromotions(with menu:Menu) -> Observable<[Promotion]>
    func requestProducts() -> Observable<[ProductResponse]>
    func requestImage(urlString: String) -> Observable<Data>
}


final class Service : ServiceProtocol {
    
    private let backgroundScheduler = ConcurrentDispatchQueueScheduler(qos: .utility)
    
    func requestPromotions(with menu:Menu) -> Observable<[Promotion]> {
        return Observable.create { observer in
            guard let url = Bundle.main.url(forResource: "Promotions\(menu.rawValue)", withExtension: "json") else {
                observer.onError(APIError.url)
                return Disposables.create()
            }
            
            do {
                let data = try Data(contentsOf: url)
                let jsonData = try JSONDecoder().decode([Promotion].self, from: data)
                observer.onNext(jsonData)
                observer.onCompleted()
            }catch {
                observer.onError(error)
            }
            
            return Disposables.create()
        }
    }
    
    func requestProducts() -> Observable<[ProductResponse]>  {
        return Observable.create { observer in
            guard let url = Bundle.main.url(forResource: "Products", withExtension: "json") else {
                observer.onError(APIError.url)
                return Disposables.create()
            }
            
            do {
                let data = try Data(contentsOf: url)
                do  {
                    let jsonData = try JSONDecoder().decode([ProductResponse].self, from: data)
                    observer.onNext(jsonData)
                    observer.onCompleted()
                }catch {
                    observer.onError(error)
                }
            }catch {
                observer.onError(error)
            }
            
            return Disposables.create()
        }
    }
    
    func requestImage(urlString: String) -> Observable<Data> {
        return Observable.create { [unowned self] observer in
            guard let url = URL(string: urlString) else {
                observer.onError(APIError.url)
                return Disposables.create()
            }
            
            let task = self.request(with: url, method: .get) { responseData, requsetError in
                if let error = requsetError {
                    observer.onError(error)

                } else if let data = responseData {
                    observer.onNext(data)
                    observer.onCompleted()
                } else {
                    observer.onError(APIError.responseData)
                }
            }
            
            return Disposables.create(with: task.cancel)
        }
    }
    
    private func request(with url: URL, method: HTTP,  completion: @escaping (Data?, Error?) -> Void) -> URLSessionDataTask {
        var request = URLRequest(url: url, timeoutInterval: 30)
        request.httpMethod = method.rawValue
        
        URLSession.shared.configuration.waitsForConnectivity = true
        let task = URLSession.shared.dataTask(with: request) { responseData, urlResponse, requsetError in
            var error: Error? = nil
            defer {
                completion(responseData, error)
            }
    
            guard requsetError == nil else {
                error = requsetError
                return
            }
            
            guard let response = urlResponse as? HTTPURLResponse else {
                error = APIError.response
                return
            }
            
            guard response.statusCode >= 200 && response.statusCode < 300 else {
                error = APIError.statusCode(response.statusCode)
                return
            }
        }
        task.resume()
        
        return task
    }
    
}
