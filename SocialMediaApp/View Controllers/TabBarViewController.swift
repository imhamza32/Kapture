//
//  TabBarViewController.swift
//  SocialMediaApp
//
//  Created by Munib Hamza on 14/12/2022.
//

import UIKit

class TabBarViewController: WHTabbarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
        centerButtonSize  = 60.0
        centerButtonBackroundColor =  .black
        centerButtonBorderWidth = 1
        centerButtonBorderColor =  #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
        centerButtonImageSize = 30
        centerButtonImage = UIImage(named: "add")
        centerButtonBackroundColor = UIColor(named: "backgroundColor")!
        
        
        // vPosition +ev value will move button Up
        // vPosition -ev value will move button Down
        setupCenetrButton(vPosition: 0) {
            print("center button clicked")
            if self.centerButtonImage == UIImage(named: "add") {
                
                // you can navigate to some view controler from here
                let typeVC = self.getRef(storyboard: .Main, identifier: SelectTypeVC.id) as! SelectTypeVC
                typeVC.mediaSelected = { image, video in
                    typeVC.dismiss(animated: true) {
                        let vc = self.getRef(storyboard: .Main, identifier: AddImageVC.id) as! AddImageVC
                        if let video {
                            print("Video selected", video.url)
                            vc.selectedVideo = video
                            self.present(vc: vc)
                        } else if let image {
                            print("Image selected")
                            vc.selectedImage = image
                            self.present(vc: vc)
                        }
                        self.centerButtonImage = UIImage(named: "add")
                        self.addCenterButtonImage()
                    }
                }
                typeVC.modalPresentationStyle = .overFullScreen
                self.present(vc: typeVC)
                self.centerButtonImage = UIImage(named: "x")
                self.addCenterButtonImage()
                self.animateLittle()
            }
        }
    }
}
