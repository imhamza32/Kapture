//
//  StoryCell.swift
//  SocialMediaApp
//
//  Created by Munib Hamza on 13/12/2022.
//

import UIKit

class StoryCell: UICollectionViewCell {
    
    var addStoryPressed : (()->())? = nil
    
    @IBOutlet weak var bottomVuForTap: UIView!
    @IBOutlet weak var addStoryBtn: UIButton!
    
    @IBOutlet weak var storyImgVu: UIImageView!
    @IBOutlet weak var bottomVu: UIView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var plusImg: UIImageView!
    @IBOutlet weak var imgVu: UIImageView! {
        didSet {
            imgVu.layer.cornerRadius = imgVu.bounds.height/2
        }
    }
    var shapeLayer: CALayer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        makeViewCurved()
    }

    @IBAction func addMyStory(_ sender: Any) {
        addStoryPressed?()
    }
    
    func makeViewCurved() {
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = createPath()
//        shapeLayer.strokeColor = UIColor.lightGray.cgColor
        shapeLayer.fillColor = UIColor(named: "blurColor")!.cgColor
        shapeLayer.lineWidth = 1
        //The below 4 lines are for shadow above the bar. you can skip them if you do not want a shadow
        shapeLayer.shadowOffset = CGSize(width:0, height:0)
        shapeLayer.shadowRadius = 10
        shapeLayer.shadowColor = UIColor.gray.cgColor
        shapeLayer.shadowOpacity = 0.3

        if let oldShapeLayer = self.shapeLayer {
            self.bottomVu.layer.replaceSublayer(oldShapeLayer, with: shapeLayer)
        } else {
            self.bottomVu.layer.insertSublayer(shapeLayer, at: 0)
        }
        self.shapeLayer = shapeLayer

    }
    
   
    public func createPath() -> CGPath {
        
        let height: CGFloat = 20
        let path = UIBezierPath()
        let centerWidth = self.bottomVu.frame.width / 2
        path.move(to: CGPoint(x: 0, y: 0)) // start top left
        path.addLine(to: CGPoint(x: (centerWidth - height * 2), y: 0)) // the beginning of the trough
        
        path.addCurve(to: CGPoint(x: centerWidth, y: height),
                      controlPoint1: CGPoint(x: (centerWidth - 15), y: 0), controlPoint2: CGPoint(x: centerWidth - 20, y: height))
        
        path.addCurve(to: CGPoint(x: (centerWidth + height * 2), y: 0),
                      controlPoint1: CGPoint(x: centerWidth + 20, y: height), controlPoint2: CGPoint(x: (centerWidth + 15), y: 0))
        
        path.addLine(to: CGPoint(x: self.bottomVu.frame.width, y: 0))
        path.addLine(to: CGPoint(x: self.bottomVu.frame.width, y: self.bottomVu.frame.height))
        path.addLine(to: CGPoint(x: 0, y: self.bottomVu.frame.height))
        path.close()
        
        return path.cgPath
    }
    
    
    //MARK: - Public iVars
    public var story: IGStory? {
        didSet {
            self.nameLbl.text = story?.name
            self.imgVu.downloadImageFromRefWithoutCache(ref: BaseClass().getProfilePicRef(of: story?.userId ?? ""), placeholder: "user")
        }
    }
    
    
    
    public var userDetails: (String,String)? {
        didSet {
            if let details = userDetails {
                nameLbl.text = details.0
                imgVu.setImage(url: details.1)
            }
        }
    }
    
}
