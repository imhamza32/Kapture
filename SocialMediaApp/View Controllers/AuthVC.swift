//
//  AuthVC.swift
//  SocialMediaApp
//
//  Created by Munib Hamza on 13/12/2022.
//

import UIKit
import BetterSegmentedControl
import Firebase

class AuthVC: BaseClass {
    
    @IBOutlet weak var fNameTF: UITextField!
    @IBOutlet weak var lNameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var pwTF: UITextField!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var segment: BetterSegmentedControl!
    
    var isLogin = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup() {
        fNameTF.setLeftPaddingPoints(5.0)
        lNameTF.setLeftPaddingPoints(5.0)
        emailTF.setLeftPaddingPoints(5.0)
        pwTF.setLeftPaddingPoints(5.0)
        
        segment.setupSegmentWith(titles: ["Login", "Sign Up"])
        
    }
    
    func setView(isLogin : Bool) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0) { [self] in
                fNameTF.isHidden = isLogin
                lNameTF.isHidden = isLogin
            }
        }
    }
    
    @IBAction func segmentChanged(_ sender: BetterSegmentedControl) {
        print(sender.index)
        isLogin = sender.index == 0
        setView(isLogin: isLogin)
        // Vibrate phone
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()

    }
    
    @IBAction func continuePressed(_ sender: Any) {
        //        moveToHome()
        guard let email = emailTF.text, email.isValidEmail else {
            Alerts.showOKAlertWithMessage(AC.EmailNotValid, andTitle: .Alert)
            return
        }
        
        guard let pw = pwTF.text, !pw.isEmpty else {
            Alerts.showOKAlertWithMessage("Please enter password to continue.")
            return
        }
        
        if isLogin {
            self.loginUser(with: email, and: pw)
        } else {
            guard let fName = fNameTF.text, !fName.isEmpty,
                  let lName = lNameTF.text, !lName.isEmpty else {
                Alerts.showOKAlertWithMessage("Please enter your full name.")
                return
            }
            
            let params : [String : String] = ["name": fName + " " + lName,
                                              "email": email,
                                              "fcmToken": self.getFCM()
            ]
            self.startLoading()
            
            //            let appName: String = (Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String) ?? "our app"
            
            NetworkCalls.shared.signUp(params: params, password: pw) { success, userId, err in
                self.stopLoading()
                if success {
                    Messaging.messaging().subscribe(toTopic: Constants.appAlertsTopic) { error in
                        print("Subscribed to appAlertsTopic")
                    }
                    self.moveToHome()
                } else {
                    Alerts.showAlertWithError(err)
                }
            } returnedError: { error in
                self.stopLoading()
                Alerts.showAlertWithError(error)
            }
        }
    }
    
    func loginUser(with email: String, and pw: String) {
        startLoading()
        
        Auth.auth().signIn(withEmail: email, password: pw) { [weak self] authResult, error in
            guard let self else {return}
            guard let authResult, error == nil else {
                self.stopLoading()
                Alerts.showAlertWithError(error?.localizedDescription ?? AC.emailPasswordInvalid)
                return
            }
            let userId = authResult.user.uid
            NetworkCalls.shared.updateUserProfile(id: userId, [
                "fcmToken" : self.getFCM()
            ]) { status in
                if status {
                    print("Updated")
                    Task {
                        await NetworkCalls.shared.getUserData(id: userId) { (user) in
                            self.saveUserToDefaults(user)
                            self.stopLoading()
                            Messaging.messaging().subscribe(toTopic: Constants.appAlertsTopic) { error in
                                print("Subscribed to appAlertsTopic")
                            }
                            print("Saved Data to user defaults",user as Any)
                            self.moveToHome()
                        } errorCompletion: { (desc) in
                            self.stopLoading()
                            Alerts.showAlertWithError(desc)
                        }
                    }
                }
            }
        }
    }
    
    func moveToHome() {
        DispatchQueue.main.async {
            let window  = self.view.window
            let tabVC = self.getRef(storyboard: .Main, identifier: TabBarViewController.id)
            let nav = UINavigationController(rootViewController: tabVC)
            nav.isNavigationBarHidden = true
            window?.switchRootViewController(to: nav)
        }
    }
}
