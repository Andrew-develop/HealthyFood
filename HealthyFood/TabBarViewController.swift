//
//  TabBarViewController.swift
//  HealthyFood
//
//  Created by Sergio Ramos on 23.06.2021.
//

import UIKit

class TabBarViewController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item.title == "Профиль" {
            guard UserDefaults.standard.string(forKey: "authVerificationID") != nil
            else {
                let vc = storyboard?.instantiateViewController(withIdentifier: "login") as! LoginViewController
                self.present(vc, animated: true, completion: nil)
                return
            }
        }
    }

}
