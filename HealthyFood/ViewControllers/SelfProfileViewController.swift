//
//  SelfProfileViewController.swift
//  HealthyFood
//
//  Created by Sergio Ramos on 18.06.2021.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class SelfProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var mas : [Ad]? = []
    
    let database = Firestore.firestore()
    let storage = Storage.storage()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCells()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        database.collection("ads").whereField("phone", isEqualTo: UserDefaults.standard.string(forKey: "phone")).getDocuments() { (querySnapshot, err) in
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
        
        if let profileImg = UserDefaults.standard.string(forKey: "profileImage") {
            let ref = storage.reference(forURL: profileImg)
            let megaByte : Int64 = 1 * 1024 * 1024
            ref.getData(maxSize: megaByte) { (possibleData, error) in
                guard let data = possibleData else { return }
                self.profileImage.image = UIImage(data: data)
            }
        }
        else {
            profileImage.image = UIImage(named: "defaultProfileImage")
        }
        phoneLabel.attributedText = NSMutableAttributedString(string: UserDefaults.standard.string(forKey: "phone") ?? "", attributes: strokeTextAttributess)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        mas = []
        collectionView.reloadData()
    }

    func registerCells() {
        collectionView.register(UINib(nibName: String(describing: AdCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: AdCollectionViewCell.self))
    }
    
    @IBAction func changeProfileImage(_ sender: UIButton) {
        if UserDefaults.standard.string(forKey: "authVerificationID") != nil {
            let vc = UIImagePickerController()
            vc.sourceType = .photoLibrary
            vc.allowsEditing = true
            vc.delegate = self
            present(vc, animated: true)
        }
        else {
            let vc = storyboard?.instantiateViewController(withIdentifier: "login") as! LoginViewController
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }
        profileImage.image = image
        let ref = storage.reference().child("avatars").child(UserDefaults.standard.string(forKey: "phone")!)
        guard let imageData = image.jpegData(compressionQuality: 0.4) else { return }
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        ref.putData(imageData, metadata: metaData) { (metadata, error) in
            guard let _ = metadata else { return }
            ref.downloadURL { (url, error) in
                guard let url = url else { return }
                UserDefaults.standard.setValue(url.absoluteString, forKey: "profileImage")
            }
        }
    }
    
}

extension SelfProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (mas?.count ?? 0) + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: AdCollectionViewCell.self), for: indexPath) as? AdCollectionViewCell
        cell?.adName.attributedText = NSMutableAttributedString(string: "")
        cell?.adPrice.attributedText = NSMutableAttributedString(string: "")
        cell?.adPicture.image = nil
        cell?.backgroundColor = .none
        if indexPath.row == 0 {
            cell?.adPicture.image = UIImage(named: "plus")
            cell?.backgroundColor = #colorLiteral(red: 0.6273909211, green: 0.77995193, blue: 0.6030509472, alpha: 1)
            cell?.adPicture.contentMode = .center
        }
        else {
            let ref = storage.reference(withPath: "ads/\(mas![indexPath.row - 1].adId)/0")
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
            cell?.adName.attributedText = NSMutableAttributedString(string: mas?[indexPath.row - 1].name ?? "", attributes: strokeTextAttributes)
            cell?.adPrice.attributedText = NSMutableAttributedString(string: "\(mas![indexPath.row - 1].price)" + " руб", attributes: strokeTextAttributes)
        }
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
        if UserDefaults.standard.string(forKey: "authVerificationID") == nil {
            let vc = storyboard?.instantiateViewController(withIdentifier: "login") as! LoginViewController
            self.present(vc, animated: true, completion: nil)
        }
        else if indexPath.row == 0 {
            let vc = storyboard?.instantiateViewController(withIdentifier: "newAd") as? NewAdViewController
            self.present(vc ?? NewAdViewController(), animated: true, completion: nil)
        }
        else {
            let vc = storyboard?.instantiateViewController(withIdentifier: "ad") as? AdViewController
            vc?.ad = mas?[indexPath.row - 1]
            vc?.fromSellerPage = true
            self.present(vc!, animated: true, completion: nil)
        }
    }
    
}
