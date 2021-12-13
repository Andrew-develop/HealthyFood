//
//  AdViewController.swift
//  HealthyFood
//
//  Created by Sergio Ramos on 18.06.2021.
//

import UIKit
import FirebaseStorage
import FirebaseFirestore

class AdViewController: UIViewController {

    @IBOutlet weak var trash: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var placeForAdvertising: UIView!
    @IBOutlet weak var seller: UIButton!
    @IBOutlet weak var message: UIButton!
    
    var ad : Ad?
    var fromSellerPage : Bool?
    private var numberOfImages : Int?
    
    let storage = Storage.storage()
    let database = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        seller.layer.cornerRadius = 8
        message.layer.cornerRadius = 8
        if fromSellerPage ?? false {
            seller.isHidden = true
        }
        registerCells()
        if let phone = UserDefaults.standard.string(forKey: "phone") {
            if phone == String(ad!.phone) {
                trash.isHidden = false
                seller.isHidden = true
                message.isHidden = true
            }
        }
        nameLabel.text = ad?.name
        descLabel.text = ad?.desc
        priceLabel.text = "\(ad!.price) руб"
        let storageReference = storage.reference().child("ads").child(ad!.adId)
        storageReference.listAll { (result, error) in
            if let _ = error {}
            else {
                self.numberOfImages = result.items.count
                if result.items.count < 2 {
                    self.pageControl.isHidden = true
                }
                self.pageControl.numberOfPages = result.items.count
                self.collectionView.reloadData()
            }
        }
    }
    
    func registerCells() {
        collectionView.register(UINib(nibName: String(describing: AdImagesCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: AdImagesCollectionViewCell.self))
    }
    
    @IBAction func deleteAd(_ sender: UIButton) {
        let alert = UIAlertController(title: "Удаление", message: "Вы действительно хотите удалить объявление?", preferredStyle: .alert)
        let action = UIAlertAction(title: "Да", style: .default) { (alertAction) in
            self.database.collection("ads").document(self.ad!.adId).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
        let backAction = UIAlertAction(title: "Нет", style: .cancel, handler: nil)
        alert.addAction(action)
        alert.addAction(backAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func NewChatPage(_ sender: UIButton) {
    }
    
    @IBAction func sellerPageSegway(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "user") as? ProfileViewController
        vc?.phone = self.ad?.phone
        self.present(vc!, animated: true, completion: nil)
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}

extension AdViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if numberOfImages != 0 {
            return numberOfImages ?? 0
        }
        else {
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: AdImagesCollectionViewCell.self), for: indexPath) as? AdImagesCollectionViewCell
        let ref = storage.reference(withPath: "ads/\(ad!.adId)/\(indexPath.row)")
        let megaByte : Int64 = 1 * 1024 * 1024
        ref.getData(maxSize: megaByte) { (possibleData, error) in
            if let _ = error {
                cell?.picture.image = UIImage(named: "camera")
                cell?.picture.contentMode = .center
                cell?.picture.layer.cornerRadius = 8
                cell?.picture.backgroundColor = #colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1)
            }
            guard let data = possibleData else { return }
            cell?.picture.image = UIImage(data: data)
            cell?.picture.layer.cornerRadius = 8
        }
        return cell ?? AdImagesCollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
}

extension AdViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let x = collectionView.contentOffset.x
        let w = collectionView.bounds.size.width
        pageControl.currentPage = Int(ceil(x/w))
    }
    
}
