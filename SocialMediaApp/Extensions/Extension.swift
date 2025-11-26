//
//  Extension.swift
//  Kapture
//
//  Created by Munib Hamza on 15/12/2022.
//

import Foundation
import UIKit
import AVFoundation

// MARK: - UIViewController
extension UIViewController {
    
    func getRef(storyboard: Storyboards = .Main, identifier: String) -> UIViewController{
        print("Storyboard: ",storyboard.id, "VC: ",identifier)
        let storyboard = UIStoryboard(name: storyboard.id, bundle: Bundle.main)
        let vc = storyboard.instantiateViewController(withIdentifier: identifier)
        return vc
    }
    
    func instantiate<T: UIViewController> (appStoryboard: Storyboards) -> T {
        let storyboard = UIStoryboard(name: appStoryboard.id, bundle: nil)
        let identifier = String(describing: self)
        return storyboard.instantiateViewController(withIdentifier: identifier) as! T
    }
    
    func presentVC(storyboard: Storyboards = .Main, identifier: String) {
        print("Storyboard: ",storyboard.id, "VC: ",identifier)
        let vc = self.getRef(storyboard: storyboard, identifier: identifier)
        self.navigationController?.present(vc, animated: true)
    }
    
    func pushVC(storyboard: Storyboards = .Main, id identifier: String) {
        let vc = self.getRef(storyboard: storyboard, identifier: identifier)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func present(vc: UIViewController) {
        self.navigationController?.present(vc, animated: true)
    }
    
    func push(vc: UIViewController) {
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func popController() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func animateLittle(seconds : Double = 0.2){
        UIView.animate(withDuration: seconds) {
            self.view.layoutIfNeeded()
        }
    }
    //MARK: Delay
    func delay(_ seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }
    func animateLittle(completion : @escaping (()->Void)){
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
            self.delay(0.1) {
                completion()
            }
        }
    }
    
    func getThumbnailImageFromVideoUrl(urlStr: String, completion: @escaping ((_ image: UIImage?)->Void)) {
        
        guard let url = URL(string: urlStr) else {return}
        
        if let cacheImg = imgCache.object(forKey: urlStr as NSString) {
                completion(cacheImg)
        } else {
            if let asset = AVAsset(url: url) as? AVAsset {
                //let durationSeconds = CMTimeGetSeconds(asset.duration)
                let generator = AVAssetImageGenerator(asset: asset)
                
                generator.appliesPreferredTrackTransform = true
                
                let time = CMTimeMakeWithSeconds(3.0, preferredTimescale: 600)
                //var thumbnailImage: CGImage
                
                generator.generateCGImagesAsynchronously(forTimes: [NSValue(time: time)]) { (time, thumbnail, cmtime, result, error) in
                    if (thumbnail != nil) {
                        let img = UIImage(cgImage: thumbnail!)
                        imgCache.setObject(img, forKey: urlStr as NSString)
                        completion(img)
                    } else {
                        print(error?.localizedDescription as Any)
                    }
                }
            }
        }
    }
    
}
public extension UIWindow {

    /// Switch current root view controller with a new view controller.
    ///
    /// - Parameters:
    ///   - viewController: new view controller.
    ///   - animated: set to true to animate view controller change _(default is true)_.
    ///   - duration: animation duration in seconds _(default is 0.5)_.
    ///   - options: animataion options _(default is .transitionFlipFromRight)_.
    ///   - completion: optional completion handler called when view controller is changed.
    func switchRootViewController(to viewController: UIViewController, animated: Bool = true, duration: TimeInterval = 0.5, options: UIView.AnimationOptions = .transitionFlipFromRight, _ completion: (() -> Void)? = nil) {

        guard animated else {
            rootViewController = viewController
            return
        }

        UIView.transition(with: self, duration: duration, options: options, animations: {
            let oldState = UIView.areAnimationsEnabled
            UIView.setAnimationsEnabled(false)
            self.rootViewController = viewController
            UIView.setAnimationsEnabled(oldState)
        }, completion: { _ in
            completion?()
        })
    }

}

extension Int? {
    
    func addingDays(days : Int = 1) -> Int {
        guard let self else {
            print("Invalid timestamp")
            return -1}
        let timeInterval = TimeInterval(self)
        let date = Date(timeIntervalSince1970: timeInterval)
        return (date.dateByAddingDays(days: days).unixTimestamp)
    }
}

extension Date {
    var unixTimestamp: Int {
        return Int(self.timeIntervalSince1970)
    }
    
    func dateByAddingDays(days: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: days, to: self)!
    }
    
    
}

extension DispatchQueue {
    /// - Parameter closure: Closure to execute.
    func dispatchMainIfNeeded(_ closure: @escaping (()-> ())) {
        guard self === DispatchQueue.main && Thread.isMainThread else {
            DispatchQueue.main.async(execute: closure)
            return
        }

        closure()
    }
}
extension URL {
    func generateThumbnail() -> UIImage? {
        do {
            let asset = AVURLAsset(url: self)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            
            // Swift 5.3
            let cgImage = try imageGenerator.copyCGImage(at: .zero,
                                                         actualTime: nil)

            return UIImage(cgImage: cgImage)
        } catch {
            print(error.localizedDescription)

            return nil
        }
    }
}
extension String {
    //Validate Email
    public var isValidEmail: Bool {
        do {
            let regex = try NSRegularExpression(pattern: "[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?", options: .caseInsensitive)
            return regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count)) != nil
        } catch {
            return false
        }
    }
    //Valide Password
    public var isValidPassword: Bool {
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", "(?=^.{5,}$)[^\\s]+")
        return passwordPredicate.evaluate(with: self)
    }
    public var isValidName:Bool{
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", "[-a-zA-Z' ]{3,26}")
        return passwordPredicate.evaluate(with: self)
    }
    public var isValidPhoneNumber:Bool{
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", "^((\\+)|(00))[0-9]{6,14}$")
        return passwordPredicate.evaluate(with: self)
    }
    public var localized: String {
        return NSLocalizedString(self, comment: self)
    }
}
extension UITextField{
   @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
        }
    }
}

extension UIView
{
    func fixInView(_ container: UIView!) -> Void{
        self.translatesAutoresizingMaskIntoConstraints = false;
        self.frame = container.frame;
        container.addSubview(self);
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
    }
}
extension StringProtocol {
    var lines: [SubSequence] { split(whereSeparator: \.isNewline) }
    var removingAllExtraNewLines: String { lines.joined(separator: "\n") }
}
extension Dictionary {
    subscript(i: Int) -> (key: Key, value: Value) {
        return self[index(startIndex, offsetBy: i)]
    }
}

extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}
extension Dictionary {
    func nullKeyRemoval() -> Dictionary {
        var dict = self

        let keysToRemove = Array(dict.keys).filter { dict[$0] is NSNull }
        for key in keysToRemove {
            dict.removeValue(forKey: key)
        }

        return dict
    }
}
extension String {
    func getStringHeight(constraintedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let label =  UILabel(frame: CGRect(x: 0, y: 0, width: width, height: .greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.text = self
        label.font = font
        label.sizeToFit()
        
        return label.frame.height
    }
}

extension UIColor {
    
    func colorForHax(_ rgba:String)->UIColor{
        var red:   CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue:  CGFloat = 0.0
        var alpha: CGFloat = 1.0
        
        if rgba.hasPrefix("#") {
            let index   = rgba.index(rgba.startIndex, offsetBy: 1)
            let hex     = rgba.substring(from: index)
            let scanner = Scanner(string: hex)
            var hexValue: CUnsignedLongLong = 0
            if scanner.scanHexInt64(&hexValue) {
                switch (hex.count) {
                case 3:
                    red   = CGFloat((hexValue & 0xF00) >> 8)       / 15.0
                    green = CGFloat((hexValue & 0x0F0) >> 4)       / 15.0
                    blue  = CGFloat(hexValue & 0x00F)              / 15.0
                    break
                case 4:
                    red   = CGFloat((hexValue & 0xF000) >> 12)     / 15.0
                    green = CGFloat((hexValue & 0x0F00) >> 8)      / 15.0
                    blue  = CGFloat((hexValue & 0x00F0) >> 4)      / 15.0
                    alpha = CGFloat(hexValue & 0x000F)             / 15.0
                    break
                case 6:
                    red   = CGFloat((hexValue & 0xFF0000) >> 16)   / 255.0
                    green = CGFloat((hexValue & 0x00FF00) >> 8)    / 255.0
                    blue  = CGFloat(hexValue & 0x0000FF)           / 255.0
                    break
                case 8:
                    red   = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
                    green = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
                    blue  = CGFloat((hexValue & 0x0000FF00) >> 8)  / 255.0
                    alpha = CGFloat(hexValue & 0x000000FF)         / 255.0
                    break
                default:
                    print("Invalid RGB string, number of characters after '#' should be either 3, 4, 6 or 8", terminator: "")
                    break
                }
            } else {
                print("Scan hex error")
            }
        } else {
            print("Invalid RGB string, missing '#' as prefix", terminator: "")
        }
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}


extension NSObject {
    class var id: String {
        return String(describing: self)
    }
}

extension Date {

  /// Returns the amount of years from another date
  func years(from date: Date) -> Int {
    return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
  }
  /// Returns the amount of months from another date
  func months(from date: Date) -> Int {
    return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
  }
  /// Returns the amount of weeks from another date
  func weeks(from date: Date) -> Int {
    return Calendar.current.dateComponents([.weekOfYear], from: date, to: self).weekOfYear ?? 0
  }
  /// Returns the amount of days from another date
  func days(from date: Date) -> Int {
    return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
  }
  /// Returns the amount of hours from another date
  func hours(from date: Date) -> Int {
    return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
  }
  /// Returns the amount of minutes from another date
  func minutes(from date: Date) -> Int {
    return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
  }
  /// Returns the amount of seconds from another date
  func seconds(from date: Date) -> Int {
    return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
  }
  /// Returns the a custom time interval description from another date
  func offset(from date: Date) -> String {
    if years(from: date)  > 0 { return "\(years(from: date))y"  }
    if months(from: date) > 0 { return "\(months(from: date))M" }
    if weeks(from: date)  > 0 { return "\(weeks(from: date))w"  }
    if days(from: date)  > 0 { return "\(days(from: date))d"  }
    if hours(from: date)  > 0 { return "\(hours(from: date))h"  }
    if minutes(from: date) > 0 { return "\(minutes(from: date))m" }
    if seconds(from: date) > 0 { return "\(seconds(from: date))s" }
    return ""
  }
}

extension Int? {
    func timeAgo() -> String {
        guard let self else {
            print("Invalid timestamp")
            return ""}
        let timeInterval = TimeInterval(self)
        let date = Date(timeIntervalSince1970: timeInterval)
        return date.timeAgo() + " ago"
    }
}

extension Date {
    func timeAgo() -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.year, .month, .day, .hour, .minute, .second]
        formatter.zeroFormattingBehavior = .dropAll
        formatter.maximumUnitCount = 1
        return String(format: formatter.string(from: self, to: Date()) ?? "", locale: .current)
    }
}

func getMonthNameFromInt(month: Int) -> String {
    switch month {
    case 1:
        return "Jan"
    case 2:
        return "Feb"
    case 3:
        return "Mar"
    case 4:
        return "Apr"
    case 5:
        return "May"
    case 6:
        return "Jun"
    case 7:
        return "Jul"
    case 8:
        return "Aug"
    case 9:
        return "Sept"
    case 10:
        return "Oct"
    case 11:
        return "Nov"
    case 12:
        return "Dec"
    default:
        return ""
    }
}




/// Extend UITextView and implemented UITextViewDelegate to listen for changes
extension UITextView: UITextViewDelegate {
    
    /// Resize the placeholder when the UITextView bounds change
    override open var bounds: CGRect {
        didSet {
            self.resizePlaceholder()
        }
    }
    
    /// The UITextView placeholder text
    public var placeholder: String? {
        get {
            var placeholderText: String?
            
            if let placeholderLabel = self.viewWithTag(100) as? UILabel {
                placeholderText = placeholderLabel.text
            }
            
            return placeholderText
        }
        set {
            if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
                placeholderLabel.text = newValue
                placeholderLabel.sizeToFit()
            } else {
                self.addPlaceholder(newValue!)
            }
        }
    }
    
    /// When the UITextView did change, show or hide the label based on if the UITextView is empty or not
    ///
    /// - Parameter textView: The UITextView that got updated
    public func textViewDidChange(_ textView: UITextView) {
        if let placeholderLabel = self.viewWithTag(100) as? UILabel {
            placeholderLabel.isHidden = !self.text.isEmpty
        }
    }
    
    /// Resize the placeholder UILabel to make sure it's in the same position as the UITextView text
    private func resizePlaceholder() {
        if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
            let labelX = self.textContainer.lineFragmentPadding
            let labelY = self.textContainerInset.top - 2
            let labelWidth = self.frame.width - (labelX * 2)
            let labelHeight = placeholderLabel.frame.height

            placeholderLabel.frame = CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight)
        }
    }
    
    /// Adds a placeholder UILabel to this UITextView
    func addPlaceholder(_ placeholderText: String) {
        let placeholderLabel = UILabel()
        
        placeholderLabel.text = placeholderText
        placeholderLabel.sizeToFit()
        
        placeholderLabel.font = self.font
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.tag = 100
        
        placeholderLabel.isHidden = !self.text.isEmpty
        
        self.addSubview(placeholderLabel)
        self.resizePlaceholder()
        self.delegate = self
    }
    
}

class InteractivePopRecognizer: NSObject, UIGestureRecognizerDelegate {

    var navigationController: UINavigationController

    init(controller: UINavigationController) {
        self.navigationController = controller
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return navigationController.viewControllers.count > 1
    }

    // This is necessary because without it, subviews of your top controller can
    // cancel out your gesture recognizer on the edge.
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension UIView {
    func applyGradient(colors : [CGColor] = [(UIColor(named: "startColor")?.cgColor) ?? UIColor(red: 1, green: 0.2527923882, blue: 1, alpha: 1).cgColor, (UIColor(named: "endColor")?.cgColor) ?? UIColor(red: 0.1802595352, green: 0.06151589641, blue: 0.2927506345, alpha: 1).cgColor], isVertical : Bool = false ) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colors
        gradient.cornerRadius = self.layer.cornerRadius
        if isVertical {
            gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
            gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
        } else {
            gradient.startPoint = CGPoint(x: 0, y: 0.5)
            gradient.endPoint = CGPoint(x: 1, y: 0.5)
        }
        layer.insertSublayer(gradient, at: 0)
        return gradient
    }
}

@IBDesignable class GradientView: UIView {

    @IBInspectable var firstColor: UIColor = .clear { didSet { updateView() } }
    @IBInspectable var secondColor: UIColor = .clear { didSet { updateView() } }

    @IBInspectable var startPoint: CGPoint = CGPoint(x: 0, y: 0) { didSet { updateView() } }
    @IBInspectable var endPoint: CGPoint = CGPoint(x: 1, y: 1) { didSet { updateView() } }

    override class var layerClass: AnyClass { get { CAGradientLayer.self } }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateView()
        layer.frame = bounds
    }

    private func updateView() {
        let layer = self.layer as! CAGradientLayer
        layer.colors = [firstColor, secondColor].map {$0.cgColor}
        layer.startPoint = startPoint
        layer.endPoint = endPoint
    }
}
extension UITextField {
    func setLeftPaddingPoints(_ amount : CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}

extension UIView {

    func addGradientBorder() {
        let gradient = CAGradientLayer()
        gradient.frame =  CGRect(origin: CGPoint.zero, size: self.frame.size)
        gradient.colors = [(UIColor(named: "startColor")?.cgColor) ?? UIColor(red: 1, green: 0.2527923882, blue: 1, alpha: 1).cgColor, (UIColor(named: "endColor")?.cgColor) ?? UIColor(red: 0.1802595352, green: 0.06151589641, blue: 0.2927506345, alpha: 1).cgColor]
        let shape = CAShapeLayer()
        shape.lineWidth = 2
        shape.path = UIBezierPath(roundedRect: self.bounds.insetBy(dx: 2, dy: 2), cornerRadius: self.frame.width * 0.5).cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor
        gradient.mask = shape
        self.layer.addSublayer(gradient)
    }
  // OUTPUT 1
  func dropShadoeLeftBottom(scale: Bool = true) {
    layer.masksToBounds = false
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowOpacity = 0.5
    layer.shadowOffset = CGSize(width: -1, height: 1)
    layer.shadowRadius = 1

    layer.shadowPath = UIBezierPath(rect: bounds).cgPath
    layer.shouldRasterize = true
    layer.rasterizationScale = scale ? UIScreen.main.scale : 1
  }

  // OUTPUT 2
  func dropShadowAllSide(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
    layer.masksToBounds = false
    layer.shadowColor = color.cgColor
    layer.shadowOpacity = opacity
    layer.shadowOffset = offSet
    layer.shadowRadius = radius

    layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
    layer.shouldRasterize = true
    layer.rasterizationScale = scale ? UIScreen.main.scale : 1
  }
}
extension Array where Element : Equatable {
    var unique: [Element] {
        var uniqueValues: [Element] = []
        forEach { item in
            if !uniqueValues.contains(item) {
                uniqueValues += [item]
            }
        }
        return uniqueValues
    }
}

extension UIView {

    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }

    @IBInspectable var isDrawBorder: Bool {
        get {
            return self.layer.borderWidth > 0
        }
        set {

            self.layer.borderWidth = (newValue ? 3 : 0)
        }
    }

    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: self.layer.borderColor!)
        }
        set {
            self.layer.borderColor = newValue?.cgColor
        }
    }

    class func imageFromView(_ view: UIView) -> UIImage {

        //        UIGraphicsBeginImageContext(view.frame.size)
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, !view.isOpaque, 0.0)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}

extension String {
   func replace(string:String, replacement:String) -> String {
       return self.replacingOccurrences(of: string, with: replacement, options: NSString.CompareOptions.literal, range: nil)
   }

   func removeWhitespace() -> String {
       return self.replace(string: " ", replacement: "")
   }
    
    var removeSpecialCharacters: String {
        let okayChars = Set("-0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz")
        return self.filter {okayChars.contains($0) }
    }

 }

extension UICollectionView {

    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
        messageLabel.sizeToFit()

//        self.backgroundView = messageLabel
//        self.separatorStyle = .none
    }
    
    func restore() {
        self.backgroundView = nil
//        self.separatorStyle = .singleLine
    }

}

extension UITableView {
    func setEmptyMessageForTbl(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: "TrebuchetMS", size: 17)
        messageLabel.sizeToFit()

        self.backgroundView = messageLabel
        self.separatorStyle = .none
    }
    
    func restoreForTbl() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }

}


func randomString(length: Int) -> String {
  let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
  return String((0..<length).map{ _ in letters.randomElement()! })
}

extension UIView {
   func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
