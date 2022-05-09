//
//  NetworkManager.swift
//  SearchImageAssignment
//
//  Created by shashant on 08/05/22.
//


import Foundation

enum APIError: Error {
    case InaValidURL
    case NoData
    case DecodingError
}


class NetworkManager {
    let aPIHandler: APIHandlerDelegate
    let responseHandler: ResponseHandlerDelegate
    
    init(aPIHandler: APIHandlerDelegate = APIHandler(),
         responseHandler: ResponseHandlerDelegate = ResponseHandler()) {
        self.aPIHandler = aPIHandler
        self.responseHandler = responseHandler
    }
    
    func fetchRequest<T: Codable>(type: T.Type, url: URL, completion: @escaping(Result<T, APIError>) -> Void) {
       
        aPIHandler.fetchData(url: url) { result in
            switch result {
            case .success(let data):
                self.responseHandler.fetchModel(type: type, data: data) { decodedResult in
                    switch decodedResult {
                    case .success(let model):
                        completion(.success(model))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
    }
    
    
}


// MARK: - API Handler Handler Protocol
protocol APIHandlerDelegate {
    func fetchData(url: URL, completion: @escaping(Result<Data, APIError>) -> Void)
}

// MARK: - API Handler
class APIHandler: APIHandlerDelegate {
    func fetchData(url: URL, completion: @escaping(Result<Data, APIError>) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                return completion(.failure(.NoData))
            }
            completion(.success(data))
           
        }.resume()
    }
    
}


// MARK: - Response Handler Protocol
protocol ResponseHandlerDelegate {
    func fetchModel<T: Codable>(type: T.Type, data: Data, completion: (Result<T, APIError>) -> Void)
}

// MARK: - Response Handler
class ResponseHandler: ResponseHandlerDelegate {
    func fetchModel<T: Codable>(type: T.Type, data: Data, completion: (Result<T, APIError>) -> Void) {
        let commentResponse = try? JSONDecoder().decode(type.self, from: data)
        if let commentResponse = commentResponse {
            return completion(.success(commentResponse))
        } else {
            if type == Data.self {
                return completion(.success(data as! T))
            }
            completion(.failure(.DecodingError))
        }
    }
    
}
