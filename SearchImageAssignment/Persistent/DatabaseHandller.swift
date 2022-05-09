//
//  DatabaseHandller.swift
//  SearchImageAssignment
//
//  Created by shashant on 09/05/22.
//

import UIKit
import CoreData

final public class DatabaseHandler {
    private let viewContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func add<T:NSManagedObject>(_ type:T.Type) -> T? {
        guard let entityName = type.entity().name else { return nil}
        guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: viewContext) else { return nil }
        let object = T(entity: entity, insertInto: viewContext)
        return object
    }
    
    func save()  {
        do {
            try viewContext.save()
        } catch(let er) {
            print(er)
        }
    }
    
    func fetch<T:NSManagedObject>(_ type:T.Type) -> [T]? {
        let req = T.fetchRequest()
        do {
            let result  = try viewContext.fetch(req)
            return (result as! [T])
        } catch(let er) {
            print(er)
            return []
        }
        
    }
}
