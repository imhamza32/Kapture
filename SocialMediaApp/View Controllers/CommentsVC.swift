//
//  CommentsVC.swift
//  SocialMediaApp
//
//  Created by Munib Hamza on 15/12/2022.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift
import AVKit
import AVFoundation

class CommentsVC: BaseClass {
    
    @IBOutlet weak var tblVu: UITableView!
    @IBOutlet weak var scrollInnerVuew: UIView!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    
    var postDetails : Post? = nil
    var postComments : [Comment] = []
    var txtVuText = ""
    var isVideoPost = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblVu.delegate = self
        tblVu.dataSource = self
        tblVu.register(UINib(nibName: CommentsHeaderCell.id, bundle: nil), forCellReuseIdentifier: CommentsHeaderCell.id)
        tblVu.register(UINib(nibName: LikeCommentCell.id, bundle: nil), forCellReuseIdentifier: LikeCommentCell.id)
        tblVu.register(UINib(nibName: CommentsCell.id, bundle: nil), forCellReuseIdentifier: CommentsCell.id)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let isMyPost = postDetails?.author?.id ?? "" == getUserId()
        deleteBtn.isHidden = !isMyPost
        editBtn.setImage(UIImage(named: isMyPost ? "edit" : "report"), for: .normal)
        editBtn.isHidden = false
        getComments()
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.popController()
    }
    
    @IBAction func deleteBtnPressed(_ sender: Any) {
        Alerts.showOKAlertWithMessageWithCancelOption("Are you sure to delete this post?", andTitle: .Attention, yesTitle: "Delete") { [self] in
            Constants.firestoreRef.databaseAllPosts.document(postDetails?.id ?? "-1").delete { error in
                if let error {
                    Alerts.showAlertWithError(error)
                } else {
                    NetworkCalls.shared.updateUserProfile(id: self.getUserId(), [
                        "postsCount" : FieldValue.increment((Int64(-1)))
                    ]) { status in
                        if status{
                            self.goBack()
                        }
                    }
                }
            }
        }
    }
    @IBAction func editBtnPressed(_ sender: Any) {
        if postDetails?.author?.id ?? "" == getUserId() {
            let addPostVC = getRef(storyboard: .Main, identifier: AddImageVC.id) as! AddImageVC
            addPostVC.isForStories = false
            addPostVC.postDetails = self.postDetails
            addPostVC.dismissed = {
                self.delay(0.5) {
                    self.goBack()
                }
            }
            self.present(vc: addPostVC)
            
        } else {
            let user = readUserData()
            let userToAdd = [
                "id": user?.id ?? "",
                "name": user?.name ?? "",
                "email": user?.email ?? "",
                "fcmToken": user?.fcmToken ?? ""
            ]
            Alerts.showOKAlertWithMessageWithCancelOption("Do you really want to report this post.", andTitle: .Attention, yesTitle: "Report") { [self] in
                Constants.firestoreRef.reportedPosts.document().setData([
                    "postId" : postDetails?.id ?? "",
                    "reportedBy": userToAdd
                ], completion: { error in
                    if let error {
                        Alerts.showAlertWithError(error)
                    } else {
                        Alerts.showOKAlertWithMessage("Post reported. Admins will review your case. Thanks", andTitle: .Alert)
                    }
                })
            }
        }
    }
    
    func getComments() {
        guard let id = postDetails?.id else {
            Alerts.showAlertWithError("Post not found")
            return
        }
        self.startLoading()
        NetworkCalls.shared.getPostComments(id: id) { comments in
            self.stopLoading()
            self.postComments = comments
            DispatchQueue.main.dispatchMainIfNeeded {
                self.tblVu.reloadData()
            }
        } errorCompletion: { error in
            self.stopLoading()
            Alerts.showAlertWithError(error)
        }

    }
    
    func addComment() {
        guard let postId = postDetails?.id else {return}
        let myUser = readUserData()
        
        let user = ["id": myUser?.id ?? "-1",
                    "name": myUser?.name ?? "Someone"
        ]
        
        let params = [
            "commentText": txtVuText,
            "author": user,
            "timestamp" : Date().unixTimestamp,
            "commentsCount" : FieldValue.increment(Int64(1))
        ] as [String : Any]
        
        NetworkCalls.shared.addCommentToPost(id: postId, params: params) { [self] success, err in
            if success {
                print("Comment Sucess")
                self.txtVuText = ""
                self.getComments()
                self.sendNotificationTo(userId: postDetails?.author?.id, title: "New Comment", body: "\(myUser?.name ?? "Someone") commented on your post.")
                DispatchQueue.main.dispatchMainIfNeeded {
                    self.tblVu.reloadData()
                }
            }
        }
    }
    
    func playVideo() {
        guard isVideoPost, let url = URL(string: postDetails?.media ?? "") else {return}
        let player = AVPlayer(url: url)
        let vc = AVPlayerViewController()
        vc.player = player
        self.present(vc, animated: true) { vc.player?.play() }
    }
}

extension CommentsVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postComments.count + 2
    }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: CommentsHeaderCell.id, for: indexPath) as! CommentsHeaderCell
            cell.imgVu.image = UIImage(named: "placeholder")
            if isVideoPost {
                self.getThumbnailImageFromVideoUrl(urlStr: postDetails?.media ?? "") { image in
                    DispatchQueue.main.async {
                        cell.imgVu.image = image
                    }
                }
            } else {
                cell.imgVu.downloadImageFromRef(ref: postDetails?.media, placeholder: "placeholder")
            }
            cell.userIcon.downloadImageFromRefWithoutCache(ref: getProfilePicRef(of: postDetails?.author?.id ?? ""), placeholder: "user")
            cell.playVideoPressed = {
                self.playVideo()
            }
            cell.userVu.addTap { [self] in
                if let id = postDetails?.author?.id, id != getUserId() {
                    let vc = getRef(storyboard: .Main, identifier: OthersProfileVC.id) as! OthersProfileVC
                    vc.userId = id
                    push(vc: vc)
                }
            }

            cell.playVuForVideo.isHidden = !isVideoPost
            cell.postTimeAgoLbl.text = postDetails?.timestamp.timeAgo()
            cell.userNameLbl.text = postDetails?.author?.name ?? "Someone"
            cell.captionLbl.text = postDetails?.caption
            return cell
   
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: LikeCommentCell.id, for: indexPath) as! LikeCommentCell
            cell.setImgForLike(post: postDetails)
            cell.setImgForUprate(post: postDetails)
            cell.txtVu.text = self.txtVuText
            cell.likeCountLbl.text = "\(postDetails?.likedIDs?.count ?? 0)"
            cell.commentsCountLbl.text = "\(postComments.count)"
            cell.upratesCountLbl.text = "\(postDetails?.upratesIDs?.count ?? 0)"
            
            cell.likePressed = {
                cell.likeOrUnlikePost(post: self.postDetails)
            }
            
            cell.pinPressed = {
                cell.upratePost(post: self.postDetails)
            }
            
            cell.txtVuDidChange = { newText in
                self.txtVuText = newText
            }
            
            cell.placeholderLabel.isHidden = !txtVuText.isEmpty

            cell.postLiked = { [self] isAlreadyLiked in
                if isAlreadyLiked {
                    postDetails?.likedIDs?.removeAll(where: {$0 == getUserId()})
                } else {
                    postDetails?.likedIDs?.append(getUserId())
                }
                tableView.reloadRows(at: [indexPath], with: .none)
            }
            
            cell.postUprated = { [self] isAlreadyUprated in
                if isAlreadyUprated {
                    postDetails?.upratesIDs?.removeAll(where: {$0 == getUserId()})
                } else {
                    postDetails?.upratesIDs?.append(getUserId())
                }
                tableView.reloadRows(at: [indexPath], with: .none)
            }
            
            cell.addcommentsBtnPressed = {
                self.addComment()
            }
            
            cell.commentsPressed = { [self] in
                if (postDetails?.hideCommentsVu ?? true) {
                    postDetails?.hideCommentsVu = false
                } else {
                    postDetails?.hideCommentsVu = true
                }
                tableView.reloadRows(at: [indexPath], with: .middle)
                //                animateLittle()
            }
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: CommentsCell.id, for: indexPath) as! CommentsCell
            let comment = postComments[indexPath.row - 2]
            cell.setUp(with: comment)
            return cell
        }
    }
    
}
