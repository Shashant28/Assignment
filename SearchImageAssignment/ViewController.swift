//
//  ViewController.swift
//  SearchImageAssignment
//
//  Created by shashant on 08/05/22.
//

import UIKit

enum selectedItem:Int {
    case twoItem=2,threeItem=3,FourItem=4
}

protocol Subscription {
    func subscribe()
}

protocol FetchPhotos {
    func fetchingPhotos( for str:String)
}

class ViewController: UIViewController,UISearchBarDelegate,UICollectionViewDelegate,UICollectionViewDataSource {
 
    @IBOutlet weak var suggestionTbl: UITableView!
    
    @IBOutlet weak var photoCollectionView: UICollectionView!
    var fammBtn: HamburgerButton! = nil
    var photoVModel = PhotosViewModel()
    var currentItemInRow:selectedItem = .twoItem {
        didSet {
            self.photoCollectionView.reloadData()
        }
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var famContainingView: UIView!
    @IBOutlet weak var famItem2: RoundBtn!
    @IBOutlet weak var famItem3: RoundBtn!
    @IBOutlet weak var famItem4: RoundBtn!
    
    
    var imageArr:[PhotoModel]?
    var totalPages:Int!
    var currentpage:Int!
    var serachStr:[String]?
    
    @IBOutlet weak var viewTrailing: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.fammBtn = HamburgerButton(frame: CGRect(x: 0, y: 0, width: 45, height: 45))
        self.fammBtn.addTarget(self, action: #selector(ViewController.toggle(_:)), for:.touchUpInside)
        self.famContainingView.addSubview(fammBtn)
        self.subscribe()
    }
    
    @objc func toggle(_ sender: AnyObject!) {
        self.fammBtn.showsMenu = !self.fammBtn.showsMenu
        UIView.animate(
            withDuration: 1.0,
                    delay: 0.4,
                    options: .curveEaseInOut,
                    animations: { [weak self] in
                        self?.viewTrailing.constant = (self?.fammBtn.showsMenu == true) ? 29 : -1000;
                }) { (completed) in
                    UIView.animateKeyframes(withDuration: 1.0, delay: 0) {
                        UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1 / 3) { [weak self] in
                            self?.famItem2.alpha = (self?.fammBtn.showsMenu == true) ? 1.0 : 0;
                        }
                        UIView.addKeyframe(withRelativeStartTime: 1 / 3, relativeDuration: 1 / 3) {  [weak self] in
                            self?.famItem3.alpha = (self?.fammBtn.showsMenu == true) ? 1.0 : 0;

                        }
                        UIView.addKeyframe(withRelativeStartTime: 2 / 3, relativeDuration: 1 / 3) {  [weak self] in
                            self?.famItem4.alpha = (self?.fammBtn.showsMenu == true) ? 1.0 : 0;
                        }
                    }
                }
 
    }
    
    
    @IBAction func ItemNumberAction(_ sender: RoundBtn) {
        switch sender.tag {
        case 3 :
            currentItemInRow = .threeItem
        case 4 :
            currentItemInRow = .FourItem
        default :
            currentItemInRow = .twoItem
        }
        self.toggle(sender)
    }
}

extension ViewController {
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.fetchingPhotos(for: searchBar.text ?? "")
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageArr?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
      
        if  self.imageArr?[indexPath.row].imgData != nil {
            guard let newImage = UIImage(data: (self.imageArr?[indexPath.row].imgData)!) else { return cell}
            cell.photoHolder?.image = newImage
        }else {
            let str = self.imageArr?[indexPath.row].imageUrl ?? ""
           photoVModel.getPhotos(imageUrl: str, handler: { (img,dtm) in
                       DispatchQueue.main.async {
                           cell.photoHolder?.image = img
                           self.imageArr?[indexPath.row].imgData  = dtm
                           self.photoVModel.addToPhotoModelEntity((self.imageArr?[indexPath.row])!)
                       }
            })
        }
              
           return cell
    }
    

    
}

extension ViewController : UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: collectionView.frame.width/CGFloat(currentItemInRow.rawValue), height: collectionView.frame.width/CGFloat(currentItemInRow.rawValue))
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
            return 1
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y + photoCollectionView.frame.size.height) >= scrollView.contentSize.height {
            photoVModel.fetchPhotos(searchString: self.searchBar.text ?? "")
        }
    }
    
}

extension ViewController : Subscription
{
    
    //MARK: SUBSCRIPTION TO VIEW MODEL
    func subscribe() {
        photoVModel.apiModel.bind { [weak self]_  in
            DispatchQueue.main.async {
                self?.imageArr = self?.photoVModel.photos
                self?.photoCollectionView.reloadData()
                guard let isempty = self?.imageArr?.isEmpty else {return}
                if isempty == true {
                    self?.suggestionTbl.isHidden = false
                    self?.suggestionTbl.reloadData()
                }else {
                    self?.suggestionTbl.isHidden = true
                }
            }
        }

        photoVModel.actionsObservable.bind { res in
            switch res {
            case .loading:
                self.LoadingStart()
                print("loader is visible")
            case .notLoading:
                self.LoadingStop()
                print("loader is invisible")
            default :
                print("idle")
            }
        }
        
        photoVModel.totalPges.bind { pages in
            self.totalPages = pages!
        }
        
        photoVModel.currentpage.bind { page in
            self.currentpage = page!
        }
        
        photoVModel.searchStrings.bind { val in
            self.serachStr  = val
        }
        
    }
}

extension ViewController:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.serachStr?.count ?? 0
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SuggestionTableViewCell") as! SuggestionTableViewCell
        cell.suggestionLbl.text = self.serachStr?[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.fetchingPhotos(for: (self.serachStr?[indexPath.row])!)
        suggestionTbl.isHidden = true
    }
    
}

extension ViewController:FetchPhotos {
    func fetchingPhotos( for str:String) {
        if currentpage<=totalPages {
            photoVModel.fetchPhotos(searchString:str)
            
        }
    }
}

