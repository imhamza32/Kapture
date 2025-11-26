//
//  AppDelegate.swift
//  SocialMediaApp
//
//  Created by Munib Hamza on 12/12/2022.
//

import UIKit
import IQKeyboardManagerSwift
import FirebaseCore
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
   
    let window: UIWindow = {
        let w = UIWindow()
        w.backgroundColor = .white
        w.makeKeyAndVisible()
        return w
    }()    /// set orientations you want to be allowed in this property by default
    var orientationLock = UIInterfaceOrientationMask.portrait
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()

        IQKeyboardManager.shared.enable = true
        PushNotificationManager().registerForPushNotifications()
//        initateViewController()
        return true
    }
    
    func initateViewController() {
        let status = UserDefaults.standard.bool(forKey: Constants.status)
        print(status)
        
        if (status == true) {
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "NavigationHome")
            self.window.rootViewController = initialViewController
            self.window.makeKeyAndVisible()
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "SignInNavController")
            self.window.rootViewController = initialViewController
            self.window.makeKeyAndVisible()
        }
    }
    
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return self.orientationLock
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

