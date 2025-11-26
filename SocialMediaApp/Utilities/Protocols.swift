//
//  Protocols.swift
//
//  Created by Munib Hamza
//

import Foundation

protocol NewPostDelegate {
    func newPostAdded()
}

protocol UserSubscribed {
    func userSubscribed(user: User?, isSub : Bool)
}
