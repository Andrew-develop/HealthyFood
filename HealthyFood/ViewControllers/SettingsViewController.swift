//
//  SettingsViewController.swift
//  HealthyFood
//
//  Created by Sergio Ramos on 28.06.2021.
//

import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var subscription: UIButton!
    @IBOutlet weak var location: UIButton!
    @IBOutlet weak var login: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        [subscription, location, login].forEach { (element) in
            element?.layer.cornerRadius = 8
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        guard let _ = UserDefaults.standard.string(forKey: "authVerificationID") else {
            subscription.isHidden = true
            location.isHidden = true
            login.setTitle("Войти", for: .normal)
            return
        }
        subscription.isHidden = false
        location.isHidden = false
        login.setTitle("Выйти", for: .normal)
    }
    
    @IBAction func getSubscription(_ sender: UIButton) {
    }
    
    @IBAction func setUpLocation(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "setPointMap") as? SetLocationViewController
        self.present(vc!, animated: true, completion: nil)
    }
    
    @IBAction func signIn(_ sender: UIButton) {
        if sender.titleLabel?.text == "Выйти" {
            let alert = UIAlertController(title: "Выход", message: "Вы действительно хотите выйти?", preferredStyle: .alert)
            let action = UIAlertAction(title: "Да", style: .default) { (alertAction) in
                UserDefaults.standard.removeObject(forKey: "authVerificationID")
                self.subscription.isHidden = true
                self.location.isHidden = true
                self.login.setTitle("Войти", for: .normal)
            }
            let backAction = UIAlertAction(title: "Нет", style: .cancel, handler: nil)
            alert.addAction(action)
            alert.addAction(backAction)
            self.present(alert, animated: true, completion: nil)
        }
        else {
            let vc = storyboard?.instantiateViewController(withIdentifier: "login") as! LoginViewController
            self.present(vc, animated: true, completion: nil)
        }
    }
    
}
