//
//  ProfileViewController.swift
//  HealthyFood
//
//  Created by Sergio Ramos on 18.06.2021.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var message: UIButton!
    
    var phone : String?
    var mas : [Ad]? = []
    
    let strokeTextAttributes = [
      NSAttributedString.Key.strokeColor : UIColor.black,
      NSAttributedString.Key.foregroundColor : UIColor.white,
      NSAttributedString.Key.strokeWidth : -3.0,
      NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 18)]
      as [NSAttributedString.Key : Any]
    
    let strokeTextAttributess = [
      NSAttributedString.Key.strokeColor : UIColor.black,
      NSAttributedString.Key.foregroundColor : UIColor.white,
      NSAttributedString.Key.strokeWidth : -3.0,
      NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 22)]
      as [NSAttributedString.Key : Any]
    
    let database = Firestore.firestore()
    let storage = Storage.storage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCells()
        message.layer.cornerRadius = 8
    }
    
    override func viewWillAppear(_ animated: Bool) {
        database.collection("ads").whereField("phone", isEqualTo: phone).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    querySnapshot?.documents.forEach({ (document) in
                        let ad = Ad(name: document.data()["name"] as? String ?? "", desc: document.data()["desc"] as? String, price: document.data()["price"] as? Int ?? 0, phone: document.data()["phone"] as? String ?? "", adId: document.documentID)
                        self.mas?.append(ad)
                    })
                }
            self.collectionView.reloadData()
        }
        
        let ref = storage.reference(withPath: "avatars/\(phone)")
        let megaByte : Int64 = 1 * 1024 * 1024
        ref.getData(maxSize: megaByte) { (possibleData, error) in
            guard let data = possibleData else {
                self.profileImage.image = UIImage(named: "defaultProfileImage")
                return
            }
            self.profileImage.image = UIImage(data: data)
        }
        phoneLabel.attributedText = NSMutableAttributedString(string: phone ?? "", attributes: strokeTextAttributess)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        mas = []
        collectionView.reloadData()
    }

    func registerCells() {
        collectionView.register(UINib(nibName: String(describing: AdCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: AdCollectionViewCell.self))
    }
    
    
    @IBAction func showSellerPoint(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "showPoint") as? ShowSellerPointViewController
        vc?.phone = phone
        self.present(vc!, animated: true, completion: nil)
    }
    
    @IBAction func writeMessage(_ sender: UIButton) {
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (mas?.count ?? 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: AdCollectionViewCell.self), for: indexPath) as? AdCollectionViewCell
        cell?.adName.attributedText = NSMutableAttributedString(string: "")
        cell?.adPrice.attributedText = NSMutableAttributedString(string: "")
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

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width / 2 - 8, height: collectionView.bounds.width / 2 - 8)
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "ad") as? AdViewController
        vc?.ad = mas?[indexPath.row]
        vc?.fromSellerPage = true
        self.present(vc!, animated: true, completion: nil)
    }
    
}
