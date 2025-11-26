//
//  Alerts.swift
//  SocialMediaApp
//
//  Created by Munib Hamza on 17/12/2022.
//

import Foundation
import UIKit

class Alerts: NSObject {
    class func showAlertWithError(_ error:Error){
        let alert = UIAlertController.init(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        
        let okAction = UIAlertAction.init(title: "OK", style: .default, handler: {(action) in
            alert.dismiss(animated: true, completion: nil)
        })
        
        alert.addAction(okAction)
        
        DispatchQueue.main.dispatchMainIfNeeded {
            alert.show()
        }
    }
    
    class func showAlertWithError(_ error: String){
        let alert = UIAlertController.init(title: "Error", message: error, preferredStyle: .alert)
        
        let okAction = UIAlertAction.init(title: "OK", style: .default, handler: {(action) in
            alert.dismiss(animated: true, completion: nil)
        })
        
        alert.addAction(okAction)
        
        DispatchQueue.main.dispatchMainIfNeeded {
            alert.show()
        }
    }
    
    class func showOKAlertWithMessage(_ message: String, andTitle title: AlertType = .Alert){
        let alert = UIAlertController.init(title: title.rawValue, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "OK", style: .default, handler: {(action) in
            alert.dismiss(animated: true, completion: nil)
        })
        alert.addAction(okAction)
        
        DispatchQueue.main.dispatchMainIfNeeded {
            alert.show()
        }
    }
    
    
    class func showActionSheet(buttonTitles options: [String], closure: @escaping (Int)->()){
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(cancel)
        
        for (i,option) in options.enumerated() {
            let currentOption = UIAlertAction(title: option, style: .default) { action in
                closure(i)
            }
            actionSheet.addAction(currentOption)
        }
        
        
        DispatchQueue.main.dispatchMainIfNeeded {
            actionSheet.show()
        }
    }
    
    class func showOKAlertWithMessage(_ message: String, andTitle title: AlertType, closure:@escaping ()->()){
        let alert = UIAlertController.init(title: title.rawValue, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "OK", style: .default, handler: {(action) in
            alert.dismiss(animated: true, completion: nil)
            
            closure()
        })
        alert.addAction(okAction)
        DispatchQueue.main.dispatchMainIfNeeded {
            alert.show()
        }
        
    }
    
    class func showOKAndCancelAlertWithMessage(_ message: String, andTitle title: AlertType, OkAction:(() -> ())? = nil , cancelAction:(() -> Swift.Void)? = nil){
        
        let alert = UIAlertController.init(title: title.rawValue, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            
            if OkAction?() == nil {
                
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{(action) in
            
            if cancelAction?() != nil {
                
            }
            
        }))
        
        DispatchQueue.main.dispatchMainIfNeeded {
            alert.show()
        }
        
    }
    
    class func showOKAndCancelAlertWithMessage(_ message: String, andTitle title: AlertType,okButtonTitle:String, cancelButtonTitle:String, OkAction:(() -> Swift.Void)? = nil , cancelAction:(() -> Swift.Void)? = nil){
        
        let alert = UIAlertController.init(title: title.rawValue, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title:okButtonTitle , style: .default, handler: { action in
            
            if OkAction?() == nil {
                
            }
        }))
        
        alert.addAction(UIAlertAction(title: cancelButtonTitle, style: .cancel, handler:{(action) in
            
            if cancelAction?() != nil {
                
            }
            
        }))
        
        DispatchQueue.main.dispatchMainIfNeeded {
            alert.show()
        }
    }
    class func showOKAlertWithMessageWithCancelOption(_ message: String, andTitle title: AlertType, yesTitle: String = "Confirm", noTitle : String = "Cancel", closure: @escaping ()->()){
        let alert = UIAlertController.init(title: title.rawValue, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: yesTitle, style: .destructive, handler: {(action) in
            alert.dismiss(animated: true, completion: nil)
            closure()
        })
        
        alert.addAction(okAction)
        
        alert.addAction(UIAlertAction(title: noTitle, style: .cancel, handler: nil))
        
        DispatchQueue.main.dispatchMainIfNeeded {
            alert.activeVC()?.present(alert, animated: true, completion: nil)
        }
    }
    
    class func alertToEncourageCameraPhotoAccessInitially() {
        let alert = UIAlertController(
            title: "Alert",
            message: "Access denied! kindly give permission first.",
            preferredStyle: UIAlertController.Style.alert
        )
        alert.addAction(UIAlertAction(title: "Setting", style: .default, handler: { (alert) -> Void in
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            } else {
                // Fallback on earlier versions
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        DispatchQueue.main.dispatchMainIfNeeded {
            alert.show()
        }
    }
}

enum AlertType: String {
    case Ok = "Ok"
    case Alert = "Alert"
    case Error = "Error"
    case Confirmation = "Confirm"
    case NoInternet = "No Internet Connection"
    case Attention = "Attention"
    case Thanks = "Thanks"
    case Success = "Success"
}

extension UIViewController {
    
    
    func show() {
        present(animated: true, completion: nil)
    }
    
    func present(animated: Bool, completion: (() -> Void)?) {
        
        if var topController = Constants.rootVC {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            self.presentFromController(controller: topController, animated: true, completion: nil)
            
        }
    }
    func activeVC() -> UIViewController? {
        // Use connectedScenes to find the .foregroundActive rootViewController
        var rootVC: UIViewController?
        for scene in UIApplication.shared.connectedScenes {
            if scene.activationState == .foregroundActive {
                rootVC = (scene.delegate as? UIWindowSceneDelegate)?.window!!.rootViewController
                break
            }
        }
        // Then, find the topmost presentedVC from it.
        var presentedVC = rootVC
        while presentedVC?.presentedViewController != nil {
            presentedVC = presentedVC?.presentedViewController
        }
        return presentedVC
    }
    
    private func presentFromController(controller: UIViewController, animated: Bool, completion: (() -> Void)?) {
        if  let navVC = controller as? UINavigationController,
            let visibleVC = navVC.visibleViewController {
            presentFromController(controller: visibleVC, animated: animated, completion: completion)
        } else {
            if  let tabVC = controller as? UITabBarController,
                let selectedVC = tabVC.selectedViewController {
                presentFromController(controller: selectedVC, animated: animated, completion: completion)
            }
            else {
                controller.present(self, animated: animated, completion: completion)
            }
        }
    }
}
