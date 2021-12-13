//
//  ViewController.swift
//  HealthyFood
//
//  Created by Sergio Ramos on 18.06.2021.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class AdsViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var mas : [Ad]? = []
    var staticMas : [Ad]? = []
     
    let database = Firestore.firestore()
    let storage = Storage.storage()
    
    let strokeTextAttributes = [
      NSAttributedString.Key.strokeColor : UIColor.black,
      NSAttributedString.Key.foregroundColor : UIColor.white,
      NSAttributedString.Key.strokeWidth : -3.0,
      NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 18)]
      as [NSAttributedString.Key : Any]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.layer.shadowRadius = 1
        searchBar.layer.shadowOpacity = 0.7
        searchBar.layer.shadowOffset = CGSize(width: 2, height: 2)
        registerCells()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        database.collection("ads").getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    querySnapshot?.documents.forEach({ (document) in
                        let ad = Ad(name: document.data()["name"] as? String ?? "", desc: document.data()["desc"] as? String, price: document.data()["price"] as? Int ?? 0, phone: document.data()["phone"] as? String ?? "", adId: document.documentID)
                        self.mas?.append(ad)
                    })
                }
            self.staticMas = self.mas
            self.collectionView.reloadData()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        mas = []
        collectionView.reloadData()
    }
    
    func registerCells() {
        collectionView.register(UINib(nibName: String(describing: AdCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: AdCollectionViewCell.self))
    }
}

extension AdsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mas?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: AdCollectionViewCell.self), for: indexPath) as? AdCollectionViewCell
        cell?.adPicture.image = nil
        cell?.backgroundColor = .none
        let ref = storage.reference(withPath: "ads/\(mas![indexPath.row].adId)/0")
        let megaByte : Int64 = 1 * 1024 * 1024
        ref.getData(maxSize: megaByte) { (possibleData, error) in
            guard let data = possibleData else {
                cell?.adPicture.image = UIImage(named: "camera")
                cell?.adPicture.contentMode = .center
                cell?.backgroundColor = #colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1)
                return
            }
            cell?.adPicture.image = UIImage(data: data)
            cell?.adPicture.contentMode = .scaleAspectFill
        }
        cell?.adName.attributedText = NSMutableAttributedString(string: mas?[indexPath.row].name ?? "", attributes: strokeTextAttributes)
        cell?.adPrice.attributedText = NSMutableAttributedString(string: "\(mas![indexPath.row].price)" + " руб", attributes: strokeTextAttributes)
        cell?.layer.cornerRadius = 8
        return cell ?? AdCollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView.numberOfItems(inSection: section) == 1 {
            let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: collectionView.frame.width - flowLayout.itemSize.width)
            }
        else {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width / 2 - 8, height: collectionView.bounds.width / 2 - 8)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "ad") as? AdViewController
        vc?.ad = mas?[indexPath.row]
        self.present(vc!, animated: true, completion: nil)
    }
}

extension AdsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        mas = staticMas
        if !(searchBar.text?.isEmpty ?? false) {
            mas?.forEach({ (ad) in
                let regExp = searchBar.text!
                let regex = try! NSRegularExpression(pattern: regExp)
                let range = NSRange(location: 0, length: ad.name.count)
                if regex.firstMatch(in: ad.name, options: [], range: range) == nil {
                    if let ind = mas?.firstIndex(of: ad) {
                        mas?.remove(at: ind)
                    }
                }
            })
        }
        collectionView.reloadData()
    }
}

