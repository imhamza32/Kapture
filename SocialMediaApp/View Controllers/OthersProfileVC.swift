//
//  OthersProfileVC.swift
//  SocialMediaApp
//
//  Created by Munib Hamza on 27/12/2022.
//

import UIKit
import BetterSegmentedControl
import Firebase
import CHTCollectionViewWaterfallLayout

class OthersProfileVC: BaseClass {
    
    @IBOutlet weak var subscribedStack: UIStackView!
    @IBOutlet weak var subscribersStack: UIStackView!
    @IBOutlet weak var subscribeBtn: GradientButton!
    @IBOutlet weak var subscribedLbl: UILabel!
    @IBOutlet weak var subscribersCountLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var postCvLayout: CHTCollectionViewWaterfallLayout!
    @IBOutlet weak var bgImgVu: UIImageView!
    @IBOutlet weak var profileImgVu: UIImageView!
    @IBOutlet weak var segmentControll: BetterSegmentedControl!
    @IBOutlet weak var scrollVu: UIScrollView!
    @IBOutlet weak var postsCV: UICollectionView!

    var otherUser : User? = nil
    var userId = "-1"
    var myVideoPosts : [Post] = []
    var subscribedDelegate : UserSubscribed? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        scrollVu.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        fetchData(isForVideos: segmentControll.index == 1)
        
        subscribedStack.addTap { [self] in
            if otherUser?.subscribed ?? 0 > 0 {
                let vc = getRef(identifier: UsersListVC.id) as! UsersListVC
                vc.users = otherUser?.subscribedList ?? []
                vc.topLblText = "Subscribed"
                vc.isSubscribedView = true
                self.push(vc: vc)
            }
        }
        
        subscribersStack.addTap { [self] in
            if otherUser?.subscribers ?? 0 > 0 {
                let vc = getRef(identifier: UsersListVC.id) as! UsersListVC
                vc.users = otherUser?.subscribersList ?? []
                vc.topLblText = "Subscribers"
                vc.isSubscribedView = false
                self.push(vc: vc)
            }
        }
        
    }
    
    func setup() {
        
        //        postCvLayout.delegate = self
        postsCV.delegate = self
        postsCV.dataSource = self
        postCvLayout.itemRenderDirection = .leftToRight
        postCvLayout.columnCount = 2
        postCvLayout.minimumColumnSpacing = 4
        
        segmentControll.setupSegmentWith(titles: ["Images","Videos"])
        postsCV.register(UINib(nibName: PostCell.id, bundle: nil), forCellWithReuseIdentifier: PostCell.id)
        setContentInsets()
        let myUser = readUserData()
        var subscribed = false
        
        for users in myUser?.subscribedList ?? [] {
            if users.id == userId {
                subscribed = true
                break
            } else {
                subscribed = false
            }
        }
        
        if subscribed {
            subscribeBtn.setTitle("Subscribed", for: .normal)
        } else {
            subscribeBtn.setTitle("Subscribe", for: .normal)
        }
    }
    
    @IBAction func subscribeBtnPressed(_ sender: Any) {
        let isSubscribed = subscribeBtn.titleLabel?.text == "Subscribed"
        self.subscribeBtn.setTitle(isSubscribed ? "Subscribe" : "Subscribed", for: .normal)
         var subCount = Int(subscribersCountLbl.text ?? "0") ?? 0
        subCount = isSubscribed ? (subCount - 1) : (subCount + 1)
        subscribersCountLbl.text = "\(subCount)"
        
        NetworkCalls.shared.subscribeUser(othersUserId: userId, othersName: self.otherUser?.name ?? "Unknown", isAlreadySubscribed: isSubscribed) { status in
            if status {
                print("Subscribed")
                if !isSubscribed {
                    self.sendNotificationTo(fcm: self.otherUser?.fcmToken, title: "New subscriber", body: "\(self.getName()) " + "subscribed you.")
                }
                self.subscribedDelegate?.userSubscribed(user: self.otherUser, isSub: !isSubscribed)
            } else {
                Alerts.showAlertWithError("Something went wrong. Please try again.")
                self.subscribeBtn.setTitle(isSubscribed ? "Subscribed" : "Subscribe", for: .normal)
            }
        } errorCompletion: { error in
            Alerts.showAlertWithError(error)
            self.subscribeBtn.setTitle(isSubscribed ? "Subscribed" : "Subscribe", for: .normal)
        }       
    }
    
    func populateData() {
        nameLbl.text = self.otherUser?.name
        
        if let bg = self.otherUser?.backgroundUrl {
            bgImgVu.setImage(urlString: bg, placeHolderImage: UIImage(named: "13"), completionBlock: nil)
        }
        profileImgVu.downloadImageFromRefWithoutCache(ref: getProfilePicRef(of: otherUser?.id ?? ""), placeholder: "user")
        subscribedLbl.text = "\(self.otherUser?.subscribed ?? 0)"
        subscribersCountLbl.text = "\(self.otherUser?.subscribers ?? 0)"
        DispatchQueue.main.async {
            self.postsCV.reloadData()
        }
        
    }
    
    func fetchData(isForVideos: Bool) {
        self.startLoading()
        Task {
            await NetworkCalls.shared.getUserData(id: self.userId, completion: { user in
                self.otherUser = user
                NetworkCalls.shared.getUserPosts(id: self.userId,isVideos: isForVideos) { allPosts in
                    if isForVideos {
                        self.myVideoPosts = allPosts
                    } else {
                        self.otherUser?.posts = []
                        self.otherUser?.posts = allPosts
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
    
    @IBAction func segmentChanged(_ sender: Any) {
        fetchData(isForVideos: segmentControll.index == 1)
        // Vibrate phone
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()

    }
    
    @IBAction func goBack(_ sender: Any) {
        self.popController()
    }
}

extension OthersProfileVC : UICollectionViewDelegate, UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostCell.id, for: indexPath) as! PostCell
        var post : Post? = nil
        if segmentControll.index == 0 {
            post = self.otherUser?.posts?[indexPath.row]
            cell.videoIconVu.isHidden = true
        } else {
            post = myVideoPosts[indexPath.row]
            cell.videoIconVu.isHidden = false
        }
        cell.imgVu.image = UIImage(named: "placeholder")
        cell.setUpWith(post: post)
        cell.likeBtn.tag = indexPath.row
        cell.likePressed = {
            if self.segmentControll.index == 0 {
                cell.likeOrUnlikePost(post: self.otherUser?.posts?[indexPath.row])
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
        
        cell.upratePressed = {
            if self.segmentControll.index == 0 {
                cell.upratePost(post: self.otherUser?.posts?[indexPath.row])
            } else if self.segmentControll.index == 1 {
                cell.upratePost(post: self.myVideoPosts[indexPath.row])
            }
        }
        
        cell.postUprated = { [self] isAlreadyUprated in
            if isAlreadyUprated {
                post?.upratesIDs?.removeAll(where: {$0 == getUserId()})
            } else {
                post?.upratesIDs?.append(getUserId())
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = getRef(storyboard: .Main, identifier: CommentsVC.id) as! CommentsVC
        if segmentControll.index == 0 {
            vc.postDetails = self.otherUser?.posts?[indexPath.row]
            vc.isVideoPost = false
        } else if segmentControll.index == 1 {
            vc.postDetails = myVideoPosts[indexPath.row]
            vc.isVideoPost = true
        }
        push(vc: vc)
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if segmentControll.index == 0 {
            return self.otherUser?.posts?.count ?? 0
        } else if segmentControll.index == 1 {
            return myVideoPosts.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height : CGFloat = 0
        var width : CGFloat = 0
        if segmentControll.index == 0 {
            height = self.otherUser?.posts?[indexPath.row].height ?? 0
            width = self.otherUser?.posts?[indexPath.row].width ?? 0
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


extension OthersProfileVC : UIScrollViewDelegate {
    
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
