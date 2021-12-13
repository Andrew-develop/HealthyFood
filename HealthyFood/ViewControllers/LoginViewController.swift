//
//  LoginViewController.swift
//  HealthyFood
//
//  Created by Sergio Ramos on 19.06.2021.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    @IBOutlet weak var textFieldType: UILabel!
    @IBOutlet weak var phoneTextField: OneTimePhoneTextField!
    @IBOutlet weak var codeTextField: OneTimeCodeTextField!
    @IBOutlet weak var confirmButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Auth.auth().languageCode = "ru"
        phoneTextField.configure()
        codeTextField.configure()
        phoneTextField.didEnterLastDigit = { [weak self] code in
            if self!.isPhoneNumber(text: code) {
                let numberWithSeven = "+7" + String(code.dropFirst())
                self!.requestCode(text: numberWithSeven)
                self!.setUpCodeField()
            }
        }
        codeTextField.didEnterLastDigit = { [weak self] code in
            self!.sendCode(text: code)
        }
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func setUpCodeField() {
        phoneTextField.isHidden = true
        codeTextField.isHidden = false
        textFieldType.text = "Введите код из сообщения"
    }
    
    private func requestCode(text : String) {
        PhoneAuthProvider.provider().verifyPhoneNumber(text, uiDelegate: nil) { (verificationID, error) in
            if let error = error {
                print(error.localizedDescription)
            return
            }
            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
        }
    }
    
    private func sendCode(text : String) {
        let verificationID = UserDefaults.standard.string(forKey: "authVerificationID")
        
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID ?? "", verificationCode: text)

        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            else {
                UserDefaults.standard.set(authResult!.user.phoneNumber, forKey: "phone")
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    private func isPhoneNumber(text : String) -> Bool {
        let regExp = "8[0-9]{10}"
        let regex = try! NSRegularExpression(pattern: regExp)
        let range = NSRange(location: 0, length: text.count)
        return regex.firstMatch(in: text, options: [], range: range) != nil
    }
}
