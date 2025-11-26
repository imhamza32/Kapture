//
//  CommentsHeaderCell.swift
//  SocialMediaApp
//
//  Created by Munib Hamza on 17/12/2022.
//

import UIKit

class CommentsHeaderCell: UITableViewCell {

    @IBOutlet weak var playVuForVideo: UIView!
    @IBOutlet weak var captionLbl: UILabel!
    @IBOutlet weak var imgVu: ScaledHeightImageView!
    @IBOutlet weak var userIcon: UIImageView!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var postTimeAgoLbl: UILabel!
    @IBOutlet weak var userVu: UIView!
    var playVideoPressed : (()->())? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func playVideoTapped(_ sender: Any) {
        playVideoPressed?()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
