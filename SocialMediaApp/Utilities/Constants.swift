//
//  Constants.swift
//  LinkPod
//
//  Created by Munib Hamza on 30/08/2021.
//

import Foundation
import Firebase
import FirebaseDatabase

let likeImg = UIImage(named: "heart")
let likedImg = UIImage(named: "heartRed")

let uprateImg = UIImage(named: "uprate")
let upratedImg = UIImage(named: "uprateFilled")

typealias ErrorType = (String) -> Void
typealias StringType = (String)-> Void
typealias BoolType = (Bool) -> Void
typealias DictionaryType = ([String:String])-> Void
typealias dictionaryParameter = [String:Any]
let storeRef = Storage.storage()
let imgCache = NSCache<NSString, UIImage>()


struct Constants {
    
    static let firebaseServerKey = "AAAA-eC3AWQ:APA91bEIk1nvAeyf_nQn7PXJQoGBLVpQ9BW5vxdp37pR_VvtS08DfODzBjZaDfpK6kyTHY3B4wT0kyOP3r6bqj2-Fs44RDRXB6s4mfFL0IbkA4oC6UD2vocmroXUrTXAMPCHZmzOCky_"
    //UserDefault Keys
    static let status = "userStatus"
    static let nextBadgeToShow = "NextBadgeToShow"
    static let user = "user"
    static let appAlertsTopic = "app-alerts"
    // ===================
    static let googleClientID = ""
    static let profileUpdateNotif = Notification.Name("profileUpdate")
    static let rootVC  = UIApplication.shared.windows.first?.rootViewController
    
    struct firestoreRef {
        static let db = Firestore.firestore()
        static let databaseUser = db.collection("users")
        static let databaseAllPosts = db.collection("allPosts")
        static let reportedPosts = db.collection("reportedPosts")
        static let databaseAllStories = db.collection("stories")
    }
}

extension UIImageView {
    func downloadImageFromRefWithoutCache(ref: String?, placeholder : String) {
        DispatchQueue.main.dispatchMainIfNeeded {
            self.image = UIImage(named: placeholder)
        }
        guard let ref, ref != "", ref.hasPrefix("gs://") else {return}
        let reference = storeRef.reference(forURL: ref)
        if let cacheImg = imgCache.object(forKey: "\(reference)" as NSString) {
            DispatchQueue.main.dispatchMainIfNeeded {
                self.image = cacheImg
            }
        }
        
        reference.getData(maxSize: 27 * 1024 * 1024) { data, error in
            if let error = error {
                print(error.localizedDescription)
                // Uh-oh, an error occurred!
            } else {
                if let img = UIImage(data: data!) {
                    imgCache.setObject(img, forKey: "\(reference)" as NSString)
                    DispatchQueue.main.dispatchMainIfNeeded {
                        self.image = img
                    }
                    
                }
            }
        }
    }
    
    func downloadImageFromRef(ref: String?, placeholder : String) {
        self.image = UIImage(named: placeholder)
        guard let ref, ref != "", ref.hasPrefix("gs://") else {return}
        let reference = storeRef.reference(forURL: ref)
        if let cacheImg = imgCache.object(forKey: "\(reference)" as NSString) {
            DispatchQueue.main.dispatchMainIfNeeded {
                self.image = cacheImg
            }
        } else {
            reference.getData(maxSize: 27 * 1024 * 1024) { data, error in
                if let error = error {
                    print(error.localizedDescription)
                    // Uh-oh, an error occurred!
                } else {
                    if let img = UIImage(data: data!) {
                        imgCache.setObject(img, forKey: "\(reference)" as NSString)
                        DispatchQueue.main.dispatchMainIfNeeded {
                            self.image = img
                        }
                    }
                }
            }
        }
    }
}




internal struct AC {
    
    static let Error = "Error!"
    static let Alert = "Alert"
    static let DeviceType = "ios"
    static let Ok = "Ok"
    static let EmailNotValid = "Email is not valid."
    static let PhoneNotValid = "Phone number is not valid."
    static let EmailEmpty = "Email is empty."
    static let PhoneEmpty = "Phone number is empty"
    static let FirstNameEmpty = "First name is empty"
    static let LastNameEmpty = "Last name is empty"
    static let NameEmpty = "Name is empty"
    static let Empty = " is empty"
    static let PasswordsMisMatch = "Make sure your passwords match"
    static let LoginSuccess = "Login successful"
    static let SignUpSuccess = "Signup successful"
    static let emailPasswordInvalid = "Email or password is not valid"
    static let PasswordEmpty = "Password is empty"
    static let shortPassword = "Password must be atleast 6 digits"
    static let Success = "Success"
    static let InternetNotReachable = "Your phone does not appear to be connected to the internet. Please connect and try again"
    static let UserNameEmpty = "Username is empty"
    static let TermsAndCondition = "Terms and conditions have not been accepted"
    static let AllFieldNotFilled = "Make sure all fields are filled"
    static let fieldCanBeEmpty = "This field can not be empty"

    static let SomeThingWrong = "Some thing went wrong"
    static let SelectFromDropDown = "Please select value from Dropdown"
}

enum Storyboards {
    case Main
    var id: String {
        return String(describing: self)
    }
}


var gradientLayer: CAGradientLayer = {
    let l = CAGradientLayer()
    l.colors = [UIColor(named: "startColor")?.cgColor ?? #colorLiteral(red: 0.6148318648, green: 0.4355463386, blue: 0.9520625472, alpha: 1), UIColor(named: "endColor")?.cgColor ?? #colorLiteral(red: 0.9716541171, green: 0.3007429838, blue: 0.5172605515, alpha: 1)]
    l.startPoint = CGPoint(x: 0, y: 0.5)
    l.endPoint = CGPoint(x: 1, y: 0.5)
    return l
}()
