//
//  PhotosViewModel.swift
//  SearchImageAssignment
//
//  Created by shashant on 08/05/22.
//

import Foundation
import UIKit

enum action {
    
    case loading
    case notLoading
}

//MARK: Obsevable Class
final class Observable<T> {
   fileprivate var value: T? {
        didSet {
            
            listener!(value)
    }}
    
    init(_ value: T?) {
        self.value = value
    }
    
    private var listener: ((T?) -> Void)?
    
    func bind(_ listener: @escaping (T?) -> Void) {
        listener(value)
        self.listener = listener
    }
}

//MARK: DBSERVICE CONTTAINER
protocol DbServiceContainer {
   func addToPhotoModelEntity(_ obj: PhotoModel)
   func addToSearchCharEntity(_ obj:String)
   func fetchfromPhotoModelEntity()
   func fetchfromSearchCharEntity()
    
}

class PhotosViewModel:DbServiceContainer {
    func fetchfromPhotoModelEntity() {
        guard  let object:[PhotoModelDB]  = database.fetch(PhotoModelDB.self) else { return }

        let photos =  object.map { (res) -> PhotoModel in
               return PhotoModel(id: res.id, searcChar: res.searcChar, imgData: res.imgData, imageUrl: res.imageUrl)
         
        }.filter { $0.searcChar == searchStrings.value?.last}
        apiModel.value = photos
    }
    
    func fetchfromSearchCharEntity() {
        guard  let object:[SearchCharacter]  = database.fetch(SearchCharacter.self) else { return }
        searchStrings.value = object.map({ $0.str! })
    }
    
    
  func addToPhotoModelEntity(_ obj: PhotoModel) {
        guard  let object  = database.add(PhotoModelDB.self) else { return }
        object.imageUrl = obj.imageUrl
        object.id = obj.id
        object.searcChar = obj.searcChar
        object.imgData = obj.imgData
        database.save()
    }
    
  func addToSearchCharEntity(_ obj:String) {
        guard  let object  = database.add(SearchCharacter.self) else { return }
        object.str = obj
        database.save()
    }
    
    
    typealias intObservable = Observable<Int>
    
    let serviceHandler: PhotoFetchDelegate
    let database: DatabaseHandler
    init(serviceHandler: PhotoFetchDelegate = PhotoService(), database: DatabaseHandler = DatabaseHandler()) {
        self.serviceHandler = serviceHandler
        self.database = database
        
        if !Reachability.isConnectedToNetwork() {
            self.fetchfromSearchCharEntity()
        }
    }
    
   
    private var searchChar:String = ""
    private var photosApIData:[results]? {
        didSet {
            if photosApIData?.count == 0 {
                apiModel.value = []
            }else {
                photos.append(contentsOf: (photosApIData?.map({ res in
                    return PhotoModel(id: res.id, searcChar: searchChar, imageUrl: res.urls?.thumb)
                }) ?? [PhotoModel]()));
                apiModel.value = photos
            }
            
        }
    }
    
    var photos = [PhotoModel]()
    
    var photoDb = [PhotoModelDB]()
    
    var apiModel:Observable<[PhotoModel]> = Observable([]);
    var actionsObservable:Observable<action> = Observable(.notLoading)
    var totalPges:intObservable = Observable(1)
    var searchStrings:Observable<[String]> = Observable([])
    var currentpage:intObservable = Observable(0)
    
    func fetchPhotos(searchString str:String) {
        if str == "" {
            photos.removeAll()
            apiModel.value = photos
            return
        }
        if searchChar != str {
            searchChar = str
            if let ar = searchStrings.value {
                if !ar.contains(str) {
                    searchStrings.value?.append(str)
                    self.addToSearchCharEntity(str)
                }
            }
            
            
            photos.removeAll()
            apiModel.value = photos
            totalPges.value = 1
            currentpage.value = 1
        }
        
        actionsObservable.value = .loading
        if Reachability.isConnectedToNetwork() {
            serviceHandler.getPhotos(searchCharacter: str, isNewChar: photos.isEmpty) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let photosData):
                        print("Fetched new comments")
                        self.photosApIData  = photosData.results
                        self.actionsObservable.value = .notLoading
                        self.totalPges.value = (photosData.totalPages == 0) ? 1 : photosData.totalPages
                    case .failure(let error):
                        print(error)
                        self.photosApIData  = []
                        self.actionsObservable.value = .notLoading
                        self.totalPges.value = 1
                    }
                }
            }
        }else {
            actionsObservable.value = .notLoading
            self.fetchfromPhotoModelEntity()
        }
        
    }
    
    //MARK: 
    func getPhotos(imageUrl url:String,handler:@escaping (UIImage,Data)->Void){
        serviceHandler.downloadImage(from: url) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let photosData):
                    print("Fetched new comments")
                    guard let newImage = UIImage(data: photosData) else { return }
                    handler(newImage,photosData)
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}
