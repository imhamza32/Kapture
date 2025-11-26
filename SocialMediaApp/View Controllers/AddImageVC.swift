//
//  AddImageVC.swift
//  SocialMediaApp
//
//  Created by Munib Hamza on 14/12/2022.
//

import UIKit
//import FYPhoto
import AVFoundation
import Firebase
import FirebaseFirestore

class AddImageVC: BaseClass {
    
    @IBOutlet weak var addBtn: GradientButton!
    @IBOutlet weak var txtVu: UITextView!
    @IBOutlet weak var imgVu: ScaledHeightImageView!
    @IBOutlet weak var imgContainerVu: UIView!
    @IBOutlet weak var playImg: UIImageView!
    
    var isForStories = false
    var imgPicker = UIImagePickerController()
    var selectedImage : UIImage? = nil
    var selectedVideo : SelectedVideo? = nil
    var postDetails : Post? = nil
    var dismissed : (()->())? = nil
    var isForUpdate = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imgPicker.delegate = self
        imgVu.addTap { [self] in
            self.openImagePicker()
        }
        updateViews()
        setUp()
    }
    
    func setUp() {
        if let postDetails {
            isForUpdate = true
            txtVu.text = postDetails.caption ?? ""
            self.playImg.isHidden = !(postDetails.isVideo ?? false)
            if postDetails.isVideo ?? false {
                self.getThumbnailImageFromVideoUrl(urlStr: postDetails.media ?? "") { image in
                    DispatchQueue.main.async {
                        self.imgVu.image = image
                    }
                }
            } else {
                self.imgVu.downloadImageFromRefWithoutCache(ref: postDetails.media, placeholder: "placeholder")
            }
            addBtn.setTitle("Update Post", for: .normal)
        } else {
            isForUpdate = false
            addBtn.setTitle(isForStories ? "Add To Story" : "Add Post", for: .normal)
            self.txtVu.isHidden = isForStories
        }
        txtVu.addPlaceholder("Write a caption...")
    }
    
    
    func updateViews() {
        if let selectedVideo {
            playImg.isHidden = false
            self.imgVu.image = selectedVideo.url.generateThumbnail()
        } else if let selectedImage {
            self.imgVu.image = selectedImage
            playImg.isHidden = true
        }
        
        self.animateLittle()
    }
    
    func openImagePicker() {
        
        let vc = self.getRef(storyboard: .Main, identifier: SelectTypeVC.id) as! SelectTypeVC
        vc.makeBottomConstraintZero = true
        vc.mediaSelected = { image, video in
            self.selectedVideo = nil
            self.selectedImage = nil
            if let video {
                print("Video selected", video.url)
                self.selectedVideo = video
            } else if let image {
                print("Image selected")
                self.selectedImage = image
            }
            self.updateViews()
        }
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true)
    }
    
    
    @IBAction func pickImgPressed(_ sender: Any) {
        
        if isForUpdate {
            if selectedImage != nil || (selectedVideo?.url) != nil  {
                uploadImageOrVideo()
            } else if let text = txtVu.text, text != postDetails?.caption ?? "" {
                addPost(ref: postDetails?.media ?? "", isVideo: postDetails?.isVideo ?? false)
            }
        } else {
            uploadImageOrVideo()
        }
    }
    
    func uploadImageOrVideo() {
        
        if let selectedImage {
            
            guard let uploadData = compressImage(selectedImage: selectedImage) else {return}
            
            let fileName = (isForStories ? "storyFile" : "postFile") + "\(self.getUserId())" + "\(Date()).png"
            
            let storageReference = Storage.storage().reference().child((isForStories ? "stories" : "posts")).child(fileName)
            
            self.startLoading()
            NetworkCalls.shared.uploadFileTo(ref: storageReference, data: uploadData) { [self] success in
                
                if isForStories {
                    storageReference.downloadURL { url, error in
                        if let url {
                            self.addToMyStory(url: "\(url)", isVideo: false)
                        } else {
                            self.stopLoading()
                            Alerts.showAlertWithError(error?.localizedDescription ?? AC.SomeThingWrong)
                        }
                    }
                } else {
                    self.addPost(ref: "\(storageReference)", isVideo: false)
                }
                
            } errorCompletion: { error in
                self.stopLoading()
                Alerts.showAlertWithError(error)
            }
            
        } else if let url = selectedVideo?.url {
            
            let fileExtension = url.pathExtension
            
            let fileName = (isForStories ? "storyFile" : "postFile") + "\(self.getUserId())" + "\(Date()).\(fileExtension)"

            let storageReference = Storage.storage().reference().child((isForStories ? "stories" : "posts")).child(fileName)

            do {
                let data = try Data(contentsOf: url)
                
                self.startLoading()
                NetworkCalls.shared.uploadFileTo(ref: storageReference, data: data) { success in
                        storageReference.downloadURL { url, error in
                            if let url {
                                if self.isForStories {
                                    self.addToMyStory(url: "\(url)", isVideo: true)
                                } else {
                                    // URLs for videos
                                    self.addPost(ref: "\(url)", isVideo: true)
                                }
                            } else {
                                self.stopLoading()
                                Alerts.showAlertWithError(error?.localizedDescription ?? AC.SomeThingWrong)
                            }
                        }
                    
                } errorCompletion: { error in
                    self.stopLoading()
                    Alerts.showAlertWithError(error)
                }
            } catch let error {
                Alerts.showAlertWithError(error)
            }
        } else {
            Alerts.showOKAlertWithMessage("Please select any image or video to post.")
        }

    }
    
    func addToMyStory(url: String, isVideo: Bool) {
//        let myUser = readUserData()
        let params = [
                "id" : randomString(length: 6),
                "url": url,
                "mime_type" : isVideo ? "video" :"image",
                "last_updated" : Date().unixTimestamp,
        ] as [String : Any]
        
        NetworkCalls.shared.createStory(params: params) { success, err in
            self.stopLoading()
            if success {
                print("Story added sucessfully")
                self.imgVu.image = nil
                self.txtVu.text = nil
                self.txtVu.addPlaceholder("Write a caption...")
                self.dismiss(animated: true) {
                    NotificationCenter.default.post(name: Notification.Name("newPostAdded"), object: nil)
                }
            } else {
                Alerts.showAlertWithError(err)
            }
        }
    }
    
    func addPost(ref: String, isVideo: Bool) {
        let caption = txtVu.text ?? ""
        let size = imgVu.image!.size
        var params : [String : Any] = [:]
        let myUser = readUserData()
        let user = ["id": myUser?.id ?? "-1",
                    "name": myUser?.name ?? "Someone",
                    "profileUrl": myUser?.profileUrl ?? ""]
        params = [
            "userId": getUserId(),
            "media": ref,
            "height": size.height,
            "width": size.width,
            "isVideo" : isVideo,
            "caption": caption,
            "timestamp" :  Date().unixTimestamp,
            "author" : user
        ] as [String : Any]
       
        if let postDetails {
            NetworkCalls.shared.updatePost(postId : postDetails.id, params: params) { success, err in
                self.stopLoading()
                if success {
                    print("Post updated sucessfully")
                    self.imgVu.image = nil
                    self.txtVu.text = nil
                    self.txtVu.addPlaceholder("Write a caption...")
                    self.postDetails = nil
                    self.dismiss(animated: true) {
                        self.dismissed?()
                        NotificationCenter.default.post(name: Notification.Name("newPostAdded"), object: nil)
                    }
                } else {
                    Alerts.showAlertWithError(err)
                }
            }
        } else {
            params["likesCount"] = 0
            NetworkCalls.shared.createPost(params: params) { success, err in
                self.stopLoading()
                if success {
                    print("Post added sucessfully")
                    self.imgVu.image = nil
                    self.txtVu.text = nil
                    self.txtVu.addPlaceholder("Write a caption...")
                    self.dismiss(animated: true) {
                        NotificationCenter.default.post(name: Notification.Name("newPostAdded"), object: nil)
                    }
                } else {
                    Alerts.showAlertWithError(err)
                }
            }
        }
    }
    
    @IBAction func crossPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
}

