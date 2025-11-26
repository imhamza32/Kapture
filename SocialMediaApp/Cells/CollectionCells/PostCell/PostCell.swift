//
//  PostCell.swift
//  SocialMediaApp
//
//  Created by Munib Hamza on 13/12/2022.
//

import UIKit

class PostCell: UICollectionViewCell {
    
    var likePressed : (()->())? = nil
    var postLiked : ((Bool)->())? = nil
    var postUprated : ((Bool)->())? = nil
    var commentPressed : (()->())? = nil
    var upratePressed : (()->())? = nil
    let baseClass = BaseClass()
    ///Current user id
    var myId = ""
    @IBOutlet weak var videoIconVu: UIView!
    @IBOutlet weak var pinBtn: UIButton!
    @IBOutlet weak var commentBtn: UIButton!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var imgVu: ScaledHeightImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.myId = baseClass.getUserId()
        let doubleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(likePressed(_:)))
        doubleTap.numberOfTapsRequired = 2
        self.imgVu.isUserInteractionEnabled = true
        self.imgVu.addGestureRecognizer(doubleTap)
    }
    
    func setUpWith(post: Post?) {
        guard let post else {return}
        if post.isVideo ?? false {
            baseClass.getThumbnailImageFromVideoUrl(urlStr: post.media ?? "", completion: { image in
                DispatchQueue.main.async {
                    self.imgVu.image = image
                }
            })
        } else{
            self.imgVu.downloadImageFromRef(ref: post.media, placeholder: "placeholder")
        }
        self.videoIconVu.isHidden = !(post.isVideo ?? false)
        setImgForUprate(post: post)
        self.setImgForLike(post: post)
    }
    
    func setImgFor(isLike : Bool) {
        UIView.animate(withDuration: 0.1, animations: { [self] in
            likeBtn.transform = self.transform.scaledBy(x: 1.2, y: 1.2)
            likeBtn.setImage((isLike ? likedImg : likeImg), for: .normal)
        }, completion: { _ in
            // Step 2
            UIView.animate(withDuration: 0.1, animations: { [self] in
                likeBtn.transform = CGAffineTransform.identity
            })
        })
    }
    
    func setImgFor(isUprated : Bool) {
        UIView.animate(withDuration: 0.1, animations: { [self] in
            pinBtn.transform = self.transform.scaledBy(x: 1.2, y: 1.2)
            pinBtn.setImage((isUprated ? upratedImg : uprateImg), for: .normal)
        }, completion: { _ in
            // Step 2
            UIView.animate(withDuration: 0.1, animations: { [self] in
                pinBtn.transform = CGAffineTransform.identity
            })
        })
    }
    
    func likeOrUnlikePost(post : Post?) {
        guard let id = post?.id else {
            Alerts.showAlertWithError("Can not find this post.")
            return
        }
        if let _ = post?.likedIDs {} else {
            post?.likedIDs = []
        }
        let isAlreadyLiked = (post?.likedIDs?.contains(myId)) ?? false
        setImgFor(isLike: !isAlreadyLiked)
        self.postLiked?(isAlreadyLiked)
        NetworkCalls.shared.likeUnlikePost(id: id, isLike: !isAlreadyLiked) { [self] success, err in
            if success {
                print("Post")
                if !isAlreadyLiked {
                    baseClass.sendNotificationTo(userId: post?.author?.id, title: "Post Liked", body: "\(baseClass.getName()) liked your post.")
                }
            } else {
//                self.setImgForLike(post: post)
                Alerts.showAlertWithError(err)
            }
        }
    }
    
    func upratePost(post : Post?) {
        guard let id = post?.id else {
            Alerts.showAlertWithError("Can not find this post.")
            return
        }
        if let _ = post?.upratesIDs {} else {
            post?.upratesIDs = []
        }
        let isAlreadyUprated = (post?.upratesIDs?.contains(myId)) ?? false
        setImgFor(isUprated: !isAlreadyUprated)
        self.postUprated?(isAlreadyUprated)
        NetworkCalls.shared.upratePost(id: id, isUprate: !isAlreadyUprated) { [self] success, err in
            if success {
                print("")
                if !isAlreadyUprated {
                    baseClass.sendNotificationTo(userId: post?.author?.id, title: "Post Uprated", body: "\(baseClass.getName()) uprated your post.")
                }
            } else {
//                self.setImgForLike(post: post)
                Alerts.showAlertWithError(err)
            }
        }
    }
    
    @IBAction func likeBtnPressed(_ sender: Any) {
        likePressed?()
    }
    
    @objc func likePressed(_ sender: UITapGestureRecognizer) {
        likePressed?()
    }
    
    @IBAction func commentBtnPressed(_ sender: Any) {
        commentPressed?()
    }
    
    @IBAction func pinBtnPressed(_ sender: Any) {
        upratePressed?()
    }
    
    func setImgForUprate(post: Post?, invert: Bool = false) {
        if let isUprated = post?.upratesIDs?.contains(myId) {
            if invert {
                pinBtn.setImage((isUprated ? uprateImg : upratedImg), for: .normal)
            } else {
                pinBtn.setImage((isUprated ? upratedImg : uprateImg), for: .normal)
            }
        } else {
            pinBtn.setImage(uprateImg, for: .normal)
        }
    }
    
    
    func setImgForLike(post: Post?, invert: Bool = false) {
        if let isLiked = post?.likedIDs?.contains(myId) {
            if invert {
                likeBtn.setImage((isLiked ? likeImg : likedImg), for: .normal)
            } else {
                likeBtn.setImage((isLiked ? likedImg : likeImg), for: .normal)
            }
        } else {
            likeBtn.setImage(likeImg, for: .normal)
        }
    }
    
}
