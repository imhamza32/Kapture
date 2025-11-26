//
//  MyProfileVC.swift
//  SocialMediaApp
//
//  Created by Munib Hamza on 14/12/2022.
//

import UIKit
import BetterSegmentedControl
import Firebase
import CHTCollectionViewWaterfallLayout
import CropViewController

class MyProfileVC: BaseClass {
    @IBOutlet weak var bgImgGradient: GradientView!

    @IBOutlet weak var newBadgeLbl: UILabel!
    @IBOutlet weak var newBadgeVu: UIView! {
        didSet {
            newBadgeVu.addTap {
                self.newBadgeVu.removeFromSuperview()
            }
        }
    }
    @IBOutlet weak var newBadgeImgVu: UIImageView!
    @IBOutlet weak var postsVu: UICollectionView!
    @IBOutlet weak var badgesVu: UIView!
    @IBOutlet weak var badgesCVu: UICollectionView!
    @IBOutlet weak var subscribedLbl: UILabel!
    @IBOutlet weak var subscribersCountLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var badgesFlowLayout: CHTCollectionViewWaterfallLayout!
    @IBOutlet weak var postCvLayout: CHTCollectionViewWaterfallLayout!
    @IBOutlet weak var bgImgVu: UIImageView!
    @IBOutlet weak var profileImgVu: UIImageView!
    @IBOutlet weak var segmentControll: BetterSegmentedControl!
    @IBOutlet weak var scrollVu: UIScrollView!
    @IBOutlet weak var postsCV: UICollectionView!
    @IBOutlet weak var subscribedStack: UIStackView!
    @IBOutlet weak var subscribersStack: UIStackView!

    var once = true
    var isEditingProfilePic = true
    var user = User()
    var updateData = true
    var myVideoPosts : [Post] = []
    //array of images assets
    var badgeArray: [(title: String, details : String, earningDetails: String, image: String)] = [
        ("Founder",
         "Welcome to Kapture!\nNew Badge Earned! You can check details in badges section",
         "Welcome to Kapture!\n This badge is earned when signed up for app",
         "signUp"),
        ("Welcome Gift",
         "You just posted your first out of many posts!",
         "This badge can be earned after first post",
         "1st"),
        ("Amateur","20th post! You are an amateur photographer now.",
         "This badge can be earned after 20th post",
         "20th"),
        ("Pro",
         "Congrats you are half way to 100! \nKeep posting to become a Master",
         "This badge can be earned after 50th post",
         "50th"),
        ("Master",
         "You are a Master! Thank you for making our platform a better place with your photos and videos",
         "This badge can be earned after 100th post",
         "master")
    ]
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        profileImgVu.addTap {
            self.updateData = false
            self.isEditingProfilePic = true
            self.openImagePicker()
        }
        
        bgImgGradient.addTap {
            self.updateData = false
            self.isEditingProfilePic = false
            self.openImagePicker()
        }
        
        subscribedStack.addTap { [self] in
            if user.subscribed ?? 0 > 0 {
                let vc = getRef(identifier: UsersListVC.id) as! UsersListVC
                vc.users = user.subscribedList ?? []
                vc.topLblText = "Subscribed"
                vc.isSubscribedView = true
                vc.isFromMyProfile = true
                self.push(vc: vc)
            }
        }
        
        subscribersStack.addTap { [self] in
            if user.subscribers ?? 0 > 0 {
                let vc = getRef(identifier: UsersListVC.id) as! UsersListVC
                vc.users = user.subscribersList ?? []
                vc.topLblText = "Subscribers"
                vc.isSubscribedView = false
                vc.isFromMyProfile = true
                self.push(vc: vc)
            }
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if updateData {
            fetchData(isForVideos: segmentControll.index == 1)
        }
    }
    
    override func viewWillLayoutSubviews() {
//        var gradientLayer = CAGradientLayer()
//        if once {
//            gradientLayer = bgImgVu.applyGradient(colors: [UIColor.clear.cgColor,UIColor(named: "backgroundColor")!.cgColor], isVertical: true)
//            once = false
//        }
//        gradientLayer.frame = bgImgVu.bounds
        
    }
    
    func setup() {
        self.view.layoutIfNeeded()
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        newBadgeVu.frame = frame
        postsCV.delegate = self
        postsCV.dataSource = self
        postCvLayout.columnCount = 2
        badgesFlowLayout.columnCount = 3
        postCvLayout.minimumColumnSpacing = 4
        badgesFlowLayout.minimumColumnSpacing = 10
        segmentControll.setupSegmentWith(titles: ["Images","Videos","Badges"])
        postsCV.register(UINib(nibName: PostCell.id, bundle: nil), forCellWithReuseIdentifier: PostCell.id)
        scrollVu.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(newPostAdded), name: .init("newPostAdded"), object: nil)
        badgesCVu.dataSource = self
        badgesCVu.delegate = self
        
        badgesCVu.register(UINib(nibName: BadgesCVCell.id, bundle: nil), forCellWithReuseIdentifier: BadgesCVCell.id)

        setContentInsets()
        
    }
    
    @objc func newPostAdded() {
        if segmentControll.index < 2 {
            if updateData {
                fetchData(isForVideos: segmentControll.index == 1)
            }
        }
    }
    
    func populateData() {
        nameLbl.text = getName()
        
        if let bg = user.backgroundUrl {
            bgImgVu.downloadImageFromRef(ref: bg, placeholder: "13")
        }

        if let dp = user.profileUrl {
            profileImgVu.downloadImageFromRef(ref: dp, placeholder: "addUser")
        }
        
        subscribedLbl.text = "\(user.subscribed ?? 0)"
        subscribersCountLbl.text = "\(user.subscribers ?? 0)"
        DispatchQueue.main.async {
            self.postsCV.reloadData()
        }
        
        switch user.postsCount {
        case 100:
            if user.nextBadge == 4 {
                animateLittle {
                    self.view.addSubview(self.newBadgeVu)
                }
                self.newBadgeLbl.text = badgeArray[4].details
                self.newBadgeImgVu.image = UIImage(named: badgeArray[4].image)
                self.user.nextBadge = 5
                self.updateNextBadgeCount(badgeNo: 5)
            }
            
        case 50:
            if user.nextBadge == 3 {
                animateLittle {
                    self.view.addSubview(self.newBadgeVu)
                }
                self.newBadgeLbl.text = badgeArray[3].details
                self.newBadgeImgVu.image = UIImage(named: badgeArray[3].image)
                user.nextBadge = 4
                self.updateNextBadgeCount(badgeNo: 4)
            }
            
        case 20:
            if user.nextBadge == 2 {
                animateLittle {
                    self.view.addSubview(self.newBadgeVu)
                }
                self.newBadgeLbl.text = badgeArray[2].details
                self.newBadgeImgVu.image = UIImage(named: badgeArray[2].image)
                user.nextBadge = 3
                self.updateNextBadgeCount(badgeNo: 3)
            }
            
        case 1:
            if user.nextBadge == 1 {
                animateLittle {
                    self.view.addSubview(self.newBadgeVu)
                }
                self.newBadgeLbl.text = badgeArray[1].details
                self.newBadgeImgVu.image = UIImage(named: badgeArray[1].image)
                user.nextBadge = 2
                self.updateNextBadgeCount(badgeNo: 2)
            }
            
        default:
            if user.nextBadge == nil || user.nextBadge == 0 {
                animateLittle {
                    self.view.addSubview(self.newBadgeVu)
                }
                self.newBadgeLbl.text = badgeArray[0].details
                self.newBadgeImgVu.image = UIImage(named: badgeArray[0].image)
                user.nextBadge = 1
                self.updateNextBadgeCount(badgeNo: 1)
            }
            //Do Nothing
            break
        }
        DispatchQueue.main.async {
            self.badgesCVu.reloadData()
        }
    }
    
    func updateNextBadgeCount(badgeNo : Int) {
        NetworkCalls.shared.updateUserProfile(id: getUserId(), [
            "nextBadge" : badgeNo
        ]) { status in
            if status {
                print("Badge no updated")
            }
        }
    }
    
    func openImagePicker() {
        
        let vc = self.getRef(storyboard: .Main, identifier: SelectTypeVC.id) as! SelectTypeVC
        vc.allowVideos = false
        vc.makeBottomConstraintZero = true
        vc.mediaSelected = { image, _ in
            if let image {
                print("Image selected")
                if self.isEditingProfilePic {
                    self.aspectRatioPreset = .presetSquare
                    self.openImageCropper(image: image, isCricular: true)
                } else {
                    self.aspectRatioPreset = .preset16x9
                    self.openImageCropper(image: image)
                }
            } else {
                self.updateData = true
            }
        }
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true)
    }
    
    override func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true) {
            self.delay(1.0) {
                self.updateData = true
            }
        }
        if isEditingProfilePic  {
            setAndUploadProfilePic(image: image)
        } else {
            setAndUploadBackground(image: image)
        }
    }
    
    func setAndUploadProfilePic(image : UIImage) {
        self.profileImgVu.image = image
        self.startLoading()
        let fileName = "profilePic\(self.getUserId()).png"
        let storageReference = Storage.storage().reference().child("user").child(fileName)

        if let data = compressImage(selectedImage: image) {
            NetworkCalls.shared.uploadFileTo(ref: storageReference, data: data) { success in
                let id = self.getUserId()
                NetworkCalls.shared.updateUserProfile(id: id, [
                    "id" : id,
                    "profileUrl" : "\(storageReference)"
                ]) { status in
                    self.stopLoading()
                    if status {
                        Alerts.showOKAlertWithMessage("User profile updated successfully", andTitle: .Success)
                        let user = self.readUserData()
                        user?.profileUrl = "\(storageReference)"
                        self.saveUserToDefaults(user!)
                    } else {
                        Alerts.showAlertWithError("User profile could not be updated. Check your internet connection.")
                        self.profileImgVu.image = UIImage(named: "user")
                    }
                }
            } errorCompletion: { error in
                self.stopLoading()
                Alerts.showAlertWithError(error)
            }
        }
    }
    @IBAction func segmentChanged(_ sender: Any) {
        animateLittle { [self] in
            let showBadgesVu = segmentControll.index == 2
            postsVu.isHidden = showBadgesVu
            badgesVu.isHidden = !showBadgesVu
            DispatchQueue.main.async {
                self.scrollVu.setContentOffset(.zero, animated: true)
                if showBadgesVu {
                    self.postsCV.setContentOffset(.zero, animated: true)
                    self.badgesCVu.reloadData()
                } else {
                    self.postsCV.setContentOffset(.zero, animated: true)
                    self.postsCV.reloadData()
                }
                // Vibrate phone
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            }
        }
        if segmentControll.index < 2 {
            fetchData(isForVideos: segmentControll.index == 1)
        }
    }
    
    func setAndUploadBackground(image : UIImage) {
        self.bgImgVu.image = image
        self.startLoading()
        let fileName = "backgroundImage\(self.getUserId()).png"
        let storageReference = Storage.storage().reference().child("user").child(fileName)

        if let data = compressImage(selectedImage: image) {
            NetworkCalls.shared.uploadFileTo(ref: storageReference, data: data) { success in
                let id = self.getUserId()
                NetworkCalls.shared.updateUserProfile(id: id, [
                    "id" : id,
                    "backgroundUrl" : "\(storageReference)"
                ]) { status in
                    self.stopLoading()
                    if status {
                        Alerts.showOKAlertWithMessage("Cover pic updated successfully", andTitle: .Success)
                        let user = self.readUserData()
                        user?.backgroundUrl = "\(storageReference)"
                        self.saveUserToDefaults(user!)
                    } else {
                        Alerts.showAlertWithError("Cover pic could not be updated. Check your internet connection.")
                        self.bgImgVu.image = UIImage(named: "3")
                    }
                }
            } errorCompletion: { error in
                self.stopLoading()
                Alerts.showAlertWithError(error)
            }
        }
    }
    
    
    func fetchData(isForVideos: Bool) {
        self.startLoading()
        Task {
            await NetworkCalls.shared.getUserData(id: getUserId(), completion: { user in
                self.user = user
                NetworkCalls.shared.getUserPosts(id: self.getUserId(),isVideos: isForVideos) { allPosts in
                    if isForVideos {
                        self.myVideoPosts = allPosts
                    } else {
                        self.user.posts = []
                        self.user.posts = allPosts
                        self.saveUserToDefaults(self.user)
                    }
                    self.populateData()
                    self.stopLoading()
                } errorCompletion: { errorStr in
                    self.stopLoading()
                    Alerts.showAlertWithError(errorStr)
                }
            }, errorCompletion: { error in
                self.stopLoading()
                Alerts.showAlertWithError(error)
            })
        }
    }
    
    @IBAction func signOut(_ sender: Any) {
        Alerts.showOKAlertWithMessageWithCancelOption("Are you sure to Logout?", andTitle: .Attention) { [self] in
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
            } catch let signOutError as NSError {
                stopLoading()
                Alerts.showAlertWithError(signOutError)
                print("Error signing out: %@", signOutError)
                return
            }
            
            Messaging.messaging().unsubscribe(fromTopic: Constants.appAlertsTopic) { error in
              print("Subscribed to appAlertsTopic")
            }
            
            Constants.firestoreRef.databaseUser.document(self.getUserId()).updateData([
                "fcmToken":""
            ])
            
            deleteUserModel()
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let rootVC = storyboard.instantiateViewController(withIdentifier: "SignInNavController")
            self.view.window?.switchRootViewController(to: rootVC,options: .transitionFlipFromLeft)
            
        }
    }
    
}

extension MyProfileVC : UICollectionViewDelegate, UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == badgesCVu {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BadgesCVCell.id, for: indexPath) as! BadgesCVCell
            guard badgeArray.count > indexPath.item else {return cell}
            let badge = badgeArray[indexPath.item]
            cell.imageInCell.image = UIImage(named: "\(badge.image)")
            cell.labelInCell.text = badge.title
            cell.greyVu.isHidden = indexPath.item < user.nextBadge ?? 1
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostCell.id, for: indexPath) as! PostCell
            var post : Post? = nil
            cell.imgVu.image = UIImage(named: "placeholder")

            if segmentControll.index == 0 && indexPath.row < user.posts?.count ?? 0 {
                post = user.posts?[indexPath.row]
                cell.videoIconVu.isHidden = true
            } else if indexPath.row < myVideoPosts.count{
                post = myVideoPosts[indexPath.row]
                cell.videoIconVu.isHidden = false
            } else {
                return cell
            }
            
            cell.setUpWith(post: post)
            cell.likeBtn.tag = indexPath.row
            cell.likePressed = {
                if self.segmentControll.index == 0 {
                    cell.likeOrUnlikePost(post: self.user.posts?[indexPath.row])
                } else if self.segmentControll.index == 1 {
                    cell.likeOrUnlikePost(post: self.myVideoPosts[indexPath.row])
                }
            }
            cell.postLiked = { [self] isAlreadyLiked in
                if isAlreadyLiked {
                    post?.likedIDs?.removeAll(where: {$0 == getUserId()})
                } else {
                    post?.likedIDs?.append(getUserId())
                }
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = getRef(storyboard: .Main, identifier: CommentsVC.id) as! CommentsVC
        if segmentControll.index == 0 {
            vc.postDetails = user.posts?[indexPath.row]
            vc.isVideoPost = false
        } else if segmentControll.index == 1 {
            vc.postDetails = myVideoPosts[indexPath.row]
            vc.isVideoPost = true
        } else {

            animateLittle {
                self.view.addSubview(self.newBadgeVu)
            }
            
            self.newBadgeLbl.text = badgeArray[indexPath.item].earningDetails
            self.newBadgeImgVu.image = UIImage(named: badgeArray[indexPath.item].image)
            return
        }
        push(vc: vc)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if segmentControll.index == 0 {
            return user.posts?.count ?? 0
        } else if segmentControll.index == 1 {
            return myVideoPosts.count
        } else {
            return badgeArray.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == badgesCVu {
            let noOfCellsInRow = 3
            
            let size = Int((collectionView.bounds.width ) / CGFloat(noOfCellsInRow))
            
            return CGSize(width: size, height: size)
            
        } else {
            var height : CGFloat = 0
            var width : CGFloat = 0
            if segmentControll.index == 0 {
                height = user.posts?[indexPath.row].height ?? 0
                width = user.posts?[indexPath.row].width ?? 0
            } else if segmentControll.index == 1 {
                height = myVideoPosts[indexPath.row].height ?? 0
                width = myVideoPosts[indexPath.row].width ?? 0
            }
            
            if height < 100 {
                height = CGFloat.random(in: 300..<400)
            }
            height = height + 300
            
            return CGSize(width: width, height: height)
        }
    }
    
    
}

extension MyProfileVC : UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if postsCV.contentOffset.y < 270 {
            if postsCV.contentOffset.y > 0 {
                scrollVu.setContentOffset(postsCV.contentOffset, animated: false)
                
            } else {
                scrollVu.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: false)
            }
        } else {
            scrollVu.setContentOffset(CGPoint(x: 0.0, y: 270), animated: false)
        }
    }
    
    func setContentInsets () {
        postsCV.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 300, right: 0)
    }
    
}
