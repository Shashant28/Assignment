//
//  PhotoModelDb.swift
//  SearchImageAssignment
//
//  Created by shashant on 09/05/22.
//

import Foundation
import CoreData


public class PhotoModelDB:NSManagedObject {
    @NSManaged var id:String?
    @NSManaged var searcChar:String?
    @NSManaged var imgData:Data?
    @NSManaged var imageUrl:String?
}
