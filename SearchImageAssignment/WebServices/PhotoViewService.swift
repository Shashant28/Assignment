//
//  PhotoViewService.swift
//  SearchImageAssignment
//
//  Created by shashant on 08/05/22.
//

import Foundation


protocol PhotoFetchDelegate {
    
    func getPhotos(searchCharacter word:String,isNewChar:Bool,completion: @escaping(Result<PhotoAPIModel, APIError>) -> Void)
    func downloadImage(from url: String, completion:@escaping (Result<Data, APIError>)->Void)
    
}

class PhotoService: PhotoFetchDelegate  {
    
    func getPhotos(searchCharacter word:String,isNewChar:Bool,completion: @escaping(Result<PhotoAPIModel, APIError>) -> Void) {
        let endPoint = EndPoints.search(matching: word, isNew: isNewChar)
        guard let url = endPoint.url else {
            return completion(.failure(.InaValidURL))
        }
        if isConnected() {
            NetworkManager().fetchRequest(type: PhotoAPIModel.self, url: url, completion: completion)
        }
       
    }
    
    func downloadImage(from url: String, completion:@escaping (Result<Data, APIError>)->Void) {
        print("Download Started")
        guard let url = URL(string: url) else {
            return completion(.failure(.InaValidURL))
        }
        if isConnected() {
            NetworkManager().fetchRequest(type: Data.self, url: url, completion: completion)
        }
    }
    
    private func isConnected() -> Bool {
      return  Reachability.isConnectedToNetwork()
    
    }
}
