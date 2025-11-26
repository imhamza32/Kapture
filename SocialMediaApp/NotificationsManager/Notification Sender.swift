//
//  Notification Sender.swift
//  Social Media App
//

import UIKit
import Foundation
import Firebase

class PushNotificationSender {
    
    var ref: DatabaseReference!
    
    func sendPushNotification(fcmToken: String, title: String, body: String) {
        
        let url = NSURL(string: "https://fcm.googleapis.com/fcm/send")
        let postParams: [String : Any] =
        ["apns": [
            "payload": [ "aps": ["mutable-content": 1]],
            "fcm_options": []
            
        ] as AnyObject,
         "to": fcmToken,
         "data": ["type": "Notification"] as AnyObject,
         "notification": ["body": body,
                          "title": title as String? ,
                          "sound" : "default"] as AnyObject]
        //, “badge” : totalBadgeCount
        
        let request = NSMutableURLRequest(url: url! as URL)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("key=\(Constants.firebaseServerKey)", forHTTPHeaderField: "Authorization")
        do{
            request.httpBody = try JSONSerialization.data(withJSONObject: postParams, options: JSONSerialization.WritingOptions())
            print("My paramaters: \(postParams)")
        }
        catch{
            print("Caught an error: \(error)")
        }
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            if let realResponse = response as? HTTPURLResponse {
                if realResponse.statusCode == 200 {
                    print("Success")
                }
            }
            if let postString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue) as String? {
                print("POST: \(postString)")
            }
        }
        task.resume()
    }
}
