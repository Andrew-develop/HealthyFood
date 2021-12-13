//
//  NewAdViewController.swift
//  HealthyFood
//
//  Created by Sergio Ramos on 18.06.2021.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class NewAdViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var namesCollectionView: UICollectionView!
    @IBOutlet weak var picturesCollectionView: UICollectionView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var categoryControl: UISegmentedControl!
    @IBOutlet weak var choosenType: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    var price = 0
    
    var images : [UIImage]? = []
    
    let meatCategories = ["Баранина", "Говядина", "Свинина"]
    let milkCategories = ["Молоко", "Сливки", "Сметана", "Сыр", "Творог"]
    let henCategories = ["Индейка", "Курица", "Яйца"]
    let organicCategories = ["Брусника", "Груши", "Ежевика", "Ирга", "Кабачок", "Капуста", "Картофель", "Клюква", "Крыжовник", "Лук", "Малина", "Морковь", "Огурцы", "Помидоры", "Свекла", "Смородина", "Чеснок", "Яблоки"]
    let otherCategories = ["Варенье", "Компот", "Мед", "Соленье", "Чай"]
    
    let database = Firestore.firestore()
    let storage = Storage.storage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCells()
        // Do any additional setup after loading the view.
    }
    
    func registerCells() {
        namesCollectionView.register(UINib(nibName: String(describing: NamesCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: NamesCollectionViewCell.self))
        picturesCollectionView.register(UINib(nibName: String(describing: ImagesCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: ImagesCollectionViewCell.self))
    }
    
    @IBAction func okButtonTapped(_ sender: UIButton) {
        var ref: DocumentReference? = nil
        var desc : String {
            if textField.text!.isEmpty {
                return "Пользователь не оставил описание к товару"
            }
            return textField.text!
        }
        ref = database.collection("ads").addDocument(data: [
            "name": choosenType.text,
            "price": price,
            "desc": desc,
            "phone": UserDefaults.standard.string(forKey: "phone")
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                guard let images = self.images else { return }
                for i in 0..<images.count {
                    let ref = self.storage.reference().child("ads").child(ref!.documentID).child(String(i))
                    guard let imageData = images[i].jpegData(compressionQuality: 0.4) else { return }
                    let metaData = StorageMetadata()
                    metaData.contentType = "image/jpeg"
                    ref.putData(imageData, metadata: metaData) { (metadata, error) in
                        guard let _ = metadata else {
                            print("что-то пошло не так")
                            return
                        }
                    }
                }
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func sliderChanged(_ sender: UISlider) {
        price = Int(sender.value)
        priceLabel.text = String(price) + " руб"
    }
    
    @IBAction func segmentControlChanged(_ sender: UISegmentedControl) {
        namesCollectionView.reloadData()
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }
        images?.append(image)
        picturesCollectionView.reloadData()
    }
    
    
}

extension NewAdViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == namesCollectionView {
            if categoryControl.selectedSegmentIndex == 0 {
                return milkCategories.count
            }
            else if categoryControl.selectedSegmentIndex == 1 {
                return meatCategories.count
            }
            else if categoryControl.selectedSegmentIndex == 2 {
                return organicCategories.count
            }
            else if categoryControl.selectedSegmentIndex == 3 {
                return henCategories.count
            }
            else if categoryControl.selectedSegmentIndex == 4 {
                return otherCategories.count
            }
        }
        else if collectionView == picturesCollectionView {
            return (images?.count ?? 0) + 1
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == namesCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: NamesCollectionViewCell.self), for: indexPath) as? NamesCollectionViewCell
            if categoryControl.selectedSegmentIndex == 0 {
                cell?.name.text = milkCategories[indexPath.row]
            }
            else if categoryControl.selectedSegmentIndex == 1 {
                cell?.name.text = meatCategories[indexPath.row]
            }
            else if categoryControl.selectedSegmentIndex == 2 {
                cell?.name.text = organicCategories[indexPath.row]
            }
            else if categoryControl.selectedSegmentIndex == 3 {
                cell?.name.text = henCategories[indexPath.row]
            }
            else if categoryControl.selectedSegmentIndex == 4 {
                cell?.name.text = otherCategories[indexPath.row]
            }
            cell?.layer.cornerRadius = 8
            return cell ?? NamesCollectionViewCell()
        }
        else if collectionView == picturesCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ImagesCollectionViewCell.self), for: indexPath) as? ImagesCollectionViewCell
            cell?.picture.image = nil
            cell?.backgroundColor = .none
            if indexPath.row == 0 {
                cell?.picture.image = UIImage(named: "plus")
                cell?.picture.contentMode = .center
                cell?.backgroundColor = #colorLiteral(red: 0.6273909211, green: 0.77995193, blue: 0.6030509472, alpha: 1)
            }
            else {
                cell?.picture.image = images?[indexPath.row - 1]
                cell?.picture.contentMode = .scaleAspectFill
            }
            cell?.layer.cornerRadius = 8
            return cell ?? ImagesCollectionViewCell()
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == namesCollectionView {
            return CGSize(width: 84, height: 21)
        }
        else if collectionView == picturesCollectionView {
            return CGSize(width: 120, height: 202)
        }
        return CGSize()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView.numberOfItems(inSection: section) == 1 {
            let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
            return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: collectionView.frame.width - flowLayout.itemSize.width)
            }
        else {
            return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        UIView.animate(withDuration: 0.2, animations: {
            cell?.alpha = 0.5
        }) { (completed) in
            UIView.animate(withDuration: 0.2, animations: {
                cell?.alpha = 1
            })
        }
        if collectionView == namesCollectionView {
            if categoryControl.selectedSegmentIndex == 0 {
                choosenType.text = milkCategories[indexPath.row]
            }
            else if categoryControl.selectedSegmentIndex == 1 {
                choosenType.text = meatCategories[indexPath.row]
            }
            else if categoryControl.selectedSegmentIndex == 2 {
                choosenType.text = organicCategories[indexPath.row]
            }
            else if categoryControl.selectedSegmentIndex == 3 {
                choosenType.text = henCategories[indexPath.row]
            }
            else if categoryControl.selectedSegmentIndex == 4 {
                choosenType.text = otherCategories[indexPath.row]
            }
        }
        else if collectionView == picturesCollectionView {
            if indexPath.row == 0 {
                let vc = UIImagePickerController()
                vc.sourceType = .photoLibrary
                vc.allowsEditing = true
                vc.delegate = self
                present(vc, animated: true)
            }
        }
    }
}

extension NewAdViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        return newLength <= 120
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
