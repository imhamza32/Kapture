//
//  IGStories.swift
//  InstagramStories
//
//  Created by Ranjith Kumar on 9/8/17.
//  Copyright © 2017 DrawRect. All rights reserved.
//

import Foundation

public struct IGStories: Codable {
       
    public var otherStoriesCount: Int {
        return otherStories.count
    }
    
    public var otherStories: [IGStory]
    public var myStory: [IGStory]
    
    mutating func initFrom(allStories : [IGStory]) {
        let myId = BaseClass().getUserId()
        otherStories.removeAll()
        myStory.removeAll()
        for story in allStories {
            if story.userId == myId {
                myStory.append(story)
            } else {
                otherStories.append(story)
            }
        }
    }
    
    enum CodingKeys: String, CodingKey {
//        case otherStoriesCount = "other_stories_count"
        case otherStories = "other_stories"
        case myStory = "my_story"
    }
    
    func copy() throws -> IGStories {
        let data = try JSONEncoder().encode(self)
        let copy = try JSONDecoder().decode(IGStories.self, from: data)
        return copy
    }
}

extension IGStories {
    func removeCachedFile(for urlString: String) {
        IGVideoCacheManager.shared.getFile(for: urlString) { (result) in
            switch result {
            case .success(let url):
                IGVideoCacheManager.shared.clearCache(for: url.absoluteString)
            case .failure(let error):
                debugPrint("File read error: \(error)")
            }
        }
    }
    static func removeAllVideoFilesFromCache() {
        IGVideoCacheManager.shared.clearCache()
    }
}
