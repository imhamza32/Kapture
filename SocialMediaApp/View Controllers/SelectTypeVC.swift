//
//  SelectTypeVC.swift
//  SocialMediaApp
//
//  Created by Munib Hamza on 21/12/2022.
//

import UIKit
//import FYPhoto

class SelectTypeVC: BaseClass {

    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var bgVu: UIView!
    @IBOutlet weak var topVu: UIView!
    @IBOutlet weak var cameraVu: UIView!
    @IBOutlet weak var galleryVu: UIView!
    var allowVideos = true
    var makeBottomConstraintZero = false
    var mediaSelected : ((UIImage?, SelectedVideo?) -> ())? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTapGestures()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if makeBottomConstraintZero {
            bottomConstraint.constant = 0
        }
    }
    
    
    func addTapGestures() {
        
        topVu.addTap { [self] in
            self.dismiss(animated: true)
            self.mediaSelected?(nil,nil)
        }
        
        bgVu.addTap { [self] in
            self.dismiss(animated: true)
            self.mediaSelected?(nil,nil)
        }
        
        cameraVu.addTap { [self] in
            self.openPicker(shouldOpenCamera: true)
        }
        
        galleryVu.addTap { [self] in
            self.openPicker(shouldOpenCamera: false)

        }
    }
    
    func openPicker(shouldOpenCamera : Bool) {
        self.openPicker(openCameraMode: shouldOpenCamera, isIncludeVideos: allowVideos)
        self.photoPickerVC?.selectedPhotos = { [self] imagesList in
            self.dismiss(animated: true) {
                if shouldOpenCamera {
                    self.dismiss(animated: true)
                }
                self.delay(0.5) {
                    self.mediaSelected?(imagesList.first?.image, nil)
                }
            }
        }
        self.photoPickerVC?.selectedVideo = { [self] selectedResult in
            switch selectedResult {
            case .success(let video):
                self.dismiss(animated: true) {
                    if shouldOpenCamera {
                        self.dismiss(animated: true)
                    }
                    self.delay(0.5) {
                        self.mediaSelected?(video.briefImage, video)
                    }
                }
                break
            case .failure(let error):
                print("selected video error: \(error)")
            }
        }

    }
    
}
