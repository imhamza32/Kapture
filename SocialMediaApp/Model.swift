//
//  Model.swift
//  QCard
//
//  Created by Munib Hamza on 30/08/2021.
//

import Foundation
import FirebaseFirestore

class User: Codable {
    
    var id: String?
    var name: String?
    var email: String?
    var fcmToken:String?
    var profileUrl: String?
    var backgroundUrl: String?
    var subscribers: Int?
    var subscribed: Int?
    var subscribedList: [User]?
    var subscribersList: [User]?
    var posts : [Post]?
    var postsCount: Int?
    var nextBadge : Int?

    var asDict : [String:Any] {
        //This block of code used to convert object models to json string
        let jsonData = try! JSONEncoder().encode(self)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        print(jsonString)
        return jsonToDictionary(from: jsonString) ?? [:]
    }
    
    private  func jsonToDictionary(from text: String) -> [String: Any]? {
        guard let data = text.data(using: .utf8) else { return nil }
        let anyResult = try? JSONSerialization.jsonObject(with: data, options: [])
        return anyResult as? [String: Any]
    }
    
    private init() {}
    static let shared = User()
    
    init(id: String? = "", name: String? = "", email: String? = "", fcmToken: String? = "", profileUrl: String? = nil, backgroundUrl: String? = nil, subscribers: Int? = 0, subscribedList: [User]? = [], subscribersList: [User]? = [], subscribed: Int? = 0, posts : [Post] = [], postsCount : Int? = 0, nextBadge : Int? = 0) {
        self.id = id
        self.name = name
        self.email = email
        self.subscribed = subscribed
        self.subscribers = subscribers
        self.subscribedList = subscribedList
        self.subscribersList = subscribersList
        self.fcmToken = fcmToken
        self.profileUrl = profileUrl
        self.backgroundUrl = backgroundUrl
        self.posts = posts
        self.postsCount = postsCount
        self.nextBadge = nextBadge
    }
    
    func getUserId() -> String {
        return self.id ?? ""
    }
}


class Post : Codable {
       
    var id: String?
    var height: CGFloat?
    var width: CGFloat?
    var caption: String?
    var isVideo : Bool?
    var likesCount: Int?
    var upratesCount: Int?
    var media: String?
    var hideCommentsVu : Bool? = true
    var author: User?
    var timestamp : Int?
    var likedIDs : [String]?
    var upratesIDs : [String]?
    var comments : [Comment]?

    init(id: String? = nil, height: CGFloat? = nil, width: CGFloat? = nil, caption: String? = nil, isVideo: Bool? = nil, likesCount: Int? = nil, upratesCount: Int? = nil, media: String? = nil, author: User? = nil, likedIDs: [String]? = nil, upratesIDs: [String]? = nil, comments: [Comment]? = nil, timestamp: Int? = nil) {
        
        self.id = id
        self.height = height
        self.width = width
        self.caption = caption
        self.isVideo = isVideo
        self.likesCount = likesCount
        self.upratesCount = upratesCount
        self.media = media
        self.author = author
        self.likedIDs = likedIDs
        self.upratesIDs = upratesIDs
        self.comments = comments
    }

}

/// PinObject resembles whether this post should stay on top or not
class PinObject : Codable {
    var id: String?
    var userId: String?
//    var pinnedUntil : String?
    
    init(id: String? = nil, userId: String? = nil) {
        self.id = id
        self.userId = userId
//        self.pinnedUntil = pinnedUntil
    }
}

class Comment : Codable {
    var id: String?
    var commentText: String?
    var timestamp : Int?
    var author: User?
    
    internal init(id: String? = nil, commentText: String? = nil, author: User? = nil, timestamp: Int? = nil) {
        self.id = id
        self.commentText = commentText
        self.timestamp = timestamp
        self.author = author
    }
    
}

struct Notifications : Codable {
    var id : String?
    var title : String?
    var body: String?
    var userId: String?
    var timestamp: Int?

}
