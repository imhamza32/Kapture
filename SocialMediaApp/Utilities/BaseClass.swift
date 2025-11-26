//
//  BaseClass.swift
//  QCard
//
//  Created by Munib Hamza on 16/08/2021.
//


import Foundation
import UIKit
import CropViewController
import NVActivityIndicatorView
//import Firebase
import BetterSegmentedControl
//import FYPhoto
import FirebaseStorage

class BaseClass: UIViewController,UINavigationControllerDelegate, UIImagePickerControllerDelegate,CropViewControllerDelegate {
    
    var loaderIndicator : NVActivityIndicatorView? = nil
    var photoPickerVC : PhotoPickerViewController? = nil
    var imagePicker = UIImagePickerController()
    var aspectRatioPreset : CropViewControllerAspectRatioPreset = .presetCustom
//    let store = Storage.storage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loaderinit()
        imagePicker.delegate = self
//        whiteLoaderinit()
    }
    
    func saveUserToDefaults(_ value: User) {
        UserDefaults.standard.setValue(true, forKey: Constants.status)
        let dict: User = value
        UserDefaults.standard.set(try? PropertyListEncoder().encode(dict), forKey: Constants.user)
    }
    
    func openPicker(openCameraMode: Bool, isIncludeVideos : Bool = false) {
        
        var pickerConfig = FYPhotoPickerConfiguration()
        pickerConfig.selectionLimit = 1
        pickerConfig.supportCamera = true
        if isIncludeVideos {
            pickerConfig.mediaFilter = [.image, .video]
            pickerConfig.compressedQuality = .lowQuality
            pickerConfig.maximumVideoDuration = 60 // Secs
        } else {
            pickerConfig.mediaFilter = [.image]
        }
        self.photoPickerVC = PhotoPickerViewController(configuration: pickerConfig)

//        photoPickerVC.selectedPhotos = { [weak self] images in
//        //            images.forEach {
//        //                $0.asset
//        //                $0.data
//        //                $0.image
//        //            }
//        }
//
//        photoPickerVC.selectedVideo = { [weak self] selectedResult in
//            switch selectedResult {
//            case .success(let video):
//        //                video.briefImage
//        //                video.url
//                break
//            case .failure(let error):
//                print("selected video error: \(error)")
//            }
//        }
        DispatchQueue.main.dispatchMainIfNeeded {
            self.photoPickerVC!.modalPresentationStyle = .fullScreen
            self.present(self.photoPickerVC!, animated: true) {
                if openCameraMode {
                    self.photoPickerVC?.launchCamera()
                }
            }
        }
    }
    
    
    func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func readUserData() -> User? {
        
        var customer: User?
        if let data = UserDefaults.standard.value(forKey: Constants.user) as? Data {
            customer = try! PropertyListDecoder().decode(User.self, from: data)
        }
        
        return customer
    }
    
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func getProfileUrl() -> String {
                
        let user = readUserData()
        return user?.profileUrl ?? ""
    }
    
    func getFCM() -> String {
        return UserDefaults.standard.value(forKey: "FCMToken") as? String ?? ""
    }
    
    func getName() -> String {
        let user = readUserData()
        return user?.name ?? "Someone"
    }
    
    func showPermissionAlert(title: String, message: String) {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
            
            let okAction = UIAlertAction(title: "Settings", style: .default, handler: {(cAlertAction) in
                //Redirect to Settings app
                UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
            })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel)
            alertController.addAction(cancelAction)
            
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true, completion: nil)

    }
    
    func getUserId() -> String {
        let user = readUserData()
        return user?.id ?? "-1"
    }
    
    
    func getEmail() -> String {
        let user = readUserData()
        return user?.email ?? ""
    }
    
    func deleteUserModel() {
        let user = User()
        saveUserToDefaults(user)
        UserDefaults.standard.setValue(false, forKey: Constants.status)
        UserDefaults.standard.setValue(-1, forKey: Constants.nextBadgeToShow)
        print("user data deleted")
    }
    
    func sendNotificationTo(userId: String?, title : String, body: String) {
        // fetch the users name from the database
        guard let userId, userId != "", userId != getUserId() else {
            print("Id not found")
            return}
        guard userId != getUserId() else {
            print("Own user Id")
            return}
        Task {
            await NetworkCalls.shared.getUserData(id: userId, completion: { userData in
                if let fcm = userData.fcmToken, fcm != "" {
                    guard fcm != self.getFCM() else {
                        print("Own fcm")
                        return}
                    PushNotificationSender().sendPushNotification(fcmToken: fcm, title: title, body: body)
                }
            }, errorCompletion: { error in
                print("Error fetching user data so notification can;t be sent",error.localized)
            })
        }
    }
    
    func sendNotificationTo(fcm: String?, title : String, body: String) {
        guard let fcm, fcm != "", fcm != self.getFCM() else {
            print("Own fcm or not found")
            return}
        PushNotificationSender().sendPushNotification(fcmToken: fcm, title: title, body: body)
    }
    
    
    func compressImage(selectedImage : UIImage) -> Data? {
        var compression: CGFloat = 0.6 //starting compression
        let maxCompression: CGFloat = 0.05 //change to the maximum compression you want
        let maxFileSize: Int = 50000
        guard var uploadImageData = selectedImage.jpegData(compressionQuality: compression) else {
            print("ERROR: Creating photo data")
            return nil
        }
        
        while (uploadImageData.count > maxFileSize) && (compression > maxCompression) {
            compression -= 0.05
            if let compressedImageData = selectedImage.jpegData(compressionQuality: compression) {
                uploadImageData = compressedImageData
            }
        }
        
        guard let uploadImageDataFinal = selectedImage.jpegData(compressionQuality: compression) else {
            print("ERROR: Compressing final photo")
            return nil
        }
        return uploadImageDataFinal
    }

    func loaderinit() {
        loaderIndicator = NVActivityIndicatorView(frame: CGRect(x: self.view.frame.width/2 - 25, y: self.view.frame.height/2 , width: 50, height: 50), type: .circleStrokeSpin, color: UIColor(named: "AccentColor"))
        view.addSubview(loaderIndicator!)
    }

    func startLoading() {
        self.view.isUserInteractionEnabled = false
        loaderIndicator?.startAnimating()
    }
    
    func stopLoading() {
        DispatchQueue.main.dispatchMainIfNeeded {
            self.view.isUserInteractionEnabled = true
            self.loaderIndicator?.stopAnimating()
        }
        
    }
    
    func getProfilePicRef(of id: String?) -> String {
        guard let id else {return ""}
        let fileName = "profilePic\(id).png"
        let storageReference = Storage.storage().reference().child("user").child(fileName)
        return "\(storageReference)"
    }
    
    func getBackgroundRef(of id: String) -> String {
        let fileName = "backgroundImage\(id).png"
        let storageReference = Storage.storage().reference().child("user").child(fileName)
        return "\(storageReference)"
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imagePicker.dismiss(animated: true) {
                self.openImageCropper(image: image)
            }
        }
    }
    func openImageCropper(image: UIImage, isCricular : Bool = false) {
        
        let cropViewController = CropViewController( croppingStyle: isCricular ? .circular : .default, image: image)
        cropViewController.toolbar.clampButtonHidden = true
        cropViewController.doneButtonColor = UIColor.white
        cropViewController.cancelButtonColor = UIColor.red
        cropViewController.aspectRatioPreset = aspectRatioPreset
        cropViewController.aspectRatioLockEnabled = false
        cropViewController.resetAspectRatioEnabled = false
        cropViewController.delegate = self
        self.present(cropViewController, animated: true, completion: nil)
    }
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        print("Image Cropped!")
        cropViewController.dismiss(animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated: true, completion: nil)
    }
    
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }

        return nil
    }

   
//    
//  
//    func showAlert(title: String, message: String) {
//        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .`default`, handler: { _ in
//        }))
//        self.present(alert, animated: true, completion: nil)
//    }
//
//    func showAlert(title: String, message: String, onSuccess closure: @escaping () -> Void) {
//        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .`default`, handler: { _ in
//            closure()
//        }))
//        self.present(alert, animated: true, completion: nil)
//    }
//    
//    func showTwoBtnAlert (title: String, message: String,yesBtn:String,noBtn:String, onSuccess success: @escaping (Bool) -> Void) {
//        
//        let dialogMessage = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        
//        // Create OK button with action handler
//        let ok = UIAlertAction(title: yesBtn, style: .destructive, handler: { (action) -> Void in
//            
//            print("Yes button click...")
//            success(true)
//        })
//        
//        // Create Cancel button with action handlder
//        let cancel = UIAlertAction(title: noBtn, style: .cancel) { (action) -> Void in
//            print("Cancel button click...")
//            success(false)
//        }
//        
//        //Add OK and Cancel button to dialog message
//        dialogMessage.addAction(ok)
//        dialogMessage.addAction(cancel)
//        
//        // Present dialog message to user
//        self.present(dialogMessage, animated: true, completion: nil)
//    }
    
    func pushController(controller toPush: String, storyboard: String) {
        let controller = UIStoryboard(name: storyboard, bundle: nil).instantiateViewController(withIdentifier: toPush)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func getControllerRef(controller toPush: String, storyboard: String) -> UIViewController {
        return UIStoryboard(name: storyboard, bundle: nil).instantiateViewController(withIdentifier: toPush)
    }
        
    func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
}

extension BetterSegmentedControl {
    func setupSegmentWith(titles : [String]) {
        self.segments = LabelSegment.segments(withTitles: titles, normalFont: UIFont(name: "Poppins Regular", size: 14.0), normalTextColor: .white, selectedFont: UIFont(name: "Poppins Regular", size: 15.0), selectedTextColor : .white)
        var gradientLayer = self.indicatorView.applyGradient()
        gradientLayer.frame = self.indicatorView.bounds
    }
}

class ScaledHeightImageView: UIImageView {

    override var intrinsicContentSize: CGSize {

        if let myImage = self.image {
            let myImageWidth = myImage.size.width
            let myImageHeight = myImage.size.height
            let myViewWidth = self.frame.size.width
 
            let ratio = myViewWidth/myImageWidth
            let scaledHeight = myImageHeight * ratio

            return CGSize(width: myViewWidth, height: scaledHeight)
        }

        return CGSize(width: -1.0, height: -1.0)
    }

}
