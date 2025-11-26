//
//  CommentsCell.swift
//  SocialMediaApp
//
//  Created by Munib Hamza on 15/12/2022.
//

import UIKit
import FirebaseStorage

class CommentsCell: UITableViewCell {

    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var commentLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var imgVu: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setUp(with comment : Comment) {
        self.commentLbl.text = comment.commentText
        self.nameLbl.text = comment.author?.name
        self.timeLbl.text = comment.timestamp.timeAgo()
        self.imgVu.downloadImageFromRefWithoutCache(ref: BaseClass().getProfilePicRef(of: comment.author?.id ?? ""), placeholder: "user")
    }
}
