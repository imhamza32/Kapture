//
//  LikeCommentCell.swift
//  SocialMediaApp
//
//  Created by Munib Hamza on 17/12/2022.
//

import UIKit

class LikeCommentCell: UITableViewCell {
    @IBOutlet weak var addCommentStack: UIView!
    
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var commentsBtn: UIButton!
    @IBOutlet weak var pinBtn: UIButton!
    @IBOutlet weak var txtVu: UITextView!

    @IBOutlet weak var upratesCountLbl: UILabel!
    @IBOutlet weak var commentsCountLbl: UILabel!
    @IBOutlet weak var likeCountLbl: UILabel!
    var placeHolderText = "Jot down your comment"
    var txtVuDidChange : ((String) -> ())? = nil
    var postLiked : ((Bool) -> ())? = nil
    var postUprated : ((Bool) -> ())? = nil
    var likePressed : (() -> ())? = nil
    var commentsPressed : (() -> ())? = nil
    var addcommentsBtnPressed : (() -> ())? = nil
    var pinPressed : (() -> ())? = nil
    var placeholderLabel : UILabel!
    let base = BaseClass()
    var myId = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()

        placeholderLabel = UILabel()
        placeholderLabel.text = placeHolderText
        placeholderLabel.font = .italicSystemFont(ofSize: (txtVu.font?.pointSize)!)
        placeholderLabel.sizeToFit()
        txtVu.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (txtVu.font?.pointSize)! / 2)
        placeholderLabel.textColor = .tertiaryLabel
        placeholderLabel.isHidden = !txtVu.text.isEmpty
        
        myId = BaseClass().getUserId()
        txtVu.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    @IBAction func addCommentPressed(_ sender: Any) {
        guard let text = txtVu.text, !text.isEmpty else {
            Alerts.showOKAlertWithMessage("Write some comment.")
            return
        }
        addcommentsBtnPressed?()
    }
    @IBAction func likePressed(_ sender: Any) {
        likePressed?()
        setImgFor(isLike: true)
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
                print("")
                if !isAlreadyLiked {
                    base.sendNotificationTo(userId: post?.author?.id, title: "Post Liked", body: "\(base.getName()) liked your post.")
                }
            } else {
//                self.setImgForLike(post: post)
                Alerts.showAlertWithError(err)
            }
        }
    }
    
    func setImgForLike(post: Post?, invert: Bool = false) {
        if let isLiked = post?.likedIDs?.contains(myId) {
            if invert {
                likeBtn.setImage((isLiked ? likeImg : likedImg), for: .normal)
            } else {
                likeBtn.setImage((isLiked ? likedImg : likeImg), for: .normal)
            }
        }
        self.addCommentStack.isHidden = post?.hideCommentsVu ?? true
        
    }
      func setImgForUprate(post: Post?, invert: Bool = false) {
        if let isLiked = post?.upratesIDs?.contains(myId) {
            if invert {
                pinBtn.setImage((isLiked ? uprateImg : upratedImg), for: .normal)
            } else {
                pinBtn.setImage((isLiked ? upratedImg : uprateImg), for: .normal)
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
                    base.sendNotificationTo(userId: post?.author?.id, title: "Post Liked", body: "\(base.getName()) liked your post.")
                }
            } else {
                Alerts.showAlertWithError(err)
            }
        }
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
    
    
    
    @IBAction func commentPressed(_ sender: Any) {
        commentsPressed?()
    }
    @IBAction func pinPressed(_ sender: Any) {
        pinPressed?()
    }
}
extension LikeCommentCell : UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) { //Every time text changes this code is run
        placeholderLabel.isHidden = !textView.text.isEmpty
        if let textViewText = textView.text {
            txtVuDidChange?(textViewText)
        }
    }
}
