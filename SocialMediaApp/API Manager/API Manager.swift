//
//  API Manager.swift
//  API Manager
//
//  Created by Munib Hamza on 30/08/2021.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import CodableFirebase
import FirebaseFirestoreSwift
import FirebaseFirestore
import FirebaseStorage

class NetworkCalls {
    
    static let shared = NetworkCalls()
    private init() {}
    private let base = BaseClass()
    
    func signUp(params: dictionaryParameter, password: String,
                completion: @escaping (_ success: Bool,_ userId: String,_ err: String  )-> Void,
                returnedError: @escaping ErrorType) {
        
        var param = params
        Auth.auth().createUser(withEmail: param["email"] as! String, password: password) { authResult, error in
            if error == nil, let authResult {
                print(authResult.user as Any)
                //                        param["id"] = (authResult?.user.uid)!
                let user = User(id: authResult.user.uid, name: param["name"] as? String, email: param["email"] as? String, fcmToken: param["fcmToken"] as? String ?? "", profileUrl: "", backgroundUrl: "")
                
                param.removeAll()
                param = user.asDict
                
                self.base.saveUserToDefaults(user)
                
                // Create User on firebase
                Constants.firestoreRef.databaseUser.document(authResult.user.uid).setData(param) { error in
                    if let error = error {
                        print("Data could not be saved: \(error).")
                        completion(false,"", error.localizedDescription)
                    } else {
                        print("Data updated successfully!")
                        completion(true, authResult.user.uid,"")
                    }
                }
            } else {
                returnedError(error?.localizedDescription ?? AC.SomeThingWrong)
            }
        }
    }
    
    func createPost(params: dictionaryParameter, completion: @escaping (_ success: Bool,_ err: String) -> Void) {
        
        // Create Post on firebase
        let docRef = Constants.firestoreRef.databaseAllPosts.document()
        var dict = params
        dict["id"] =  docRef.documentID
        docRef.setData(dict) { error in
            if let error {
                print("Data could not be saved: \(error).")
                completion(false, error.localizedDescription)
            } else {
                self.updateUserProfile(id: self.base.getUserId(), [
                    "postsCount" : FieldValue.increment(Int64(1))
                ]) { status in
                    if status {
                        print("Data updated successfully!")
                        completion(true,"")
                    }
                }
                
            }
        }
    }
    
    func updatePost(postId: String?, params: dictionaryParameter, completion: @escaping (_ success: Bool,_ err: String) -> Void) {
        guard let postId else {return}
        // Update Post on firebase
        let docRef = Constants.firestoreRef.databaseAllPosts.document(postId)
        docRef.updateData(params) { error in
            if let error {
                print("Data could not be saved: \(error).")
                completion(false, error.localizedDescription)
            } else {
                print("Post updated successfully!")
                completion(true,"")
            }
        }
    }
    
    
    func createStory(params: dictionaryParameter, completion: @escaping (_ success: Bool,_ err: String) -> Void) {
        let myUser = base.readUserData()
        let userId = myUser?.id ?? ""
        let ref = Constants.firestoreRef.databaseAllStories.document(userId)
        ref.getDocument { (document, error) in
            guard let document else {
                completion(false, error?.localizedDescription ?? AC.SomeThingWrong)
                return
            }
            if document.exists {
                ref.updateData([
                    "snaps": FieldValue.arrayUnion([params])
                ]) { error in
                    if let error {
                        print("Data could not be saved: \(error).")
                        completion(false, error.localizedDescription)
                    } else {
                        print("Data updated successfully!")
                        completion(true,"")
                    }
                }
                
            } else {
                let dict = [
                    "id" : randomString(length: 6),
                    "userId": myUser?.id ?? "",
                    "name": myUser?.name ?? "",
                    "snaps" : [params]
                ]
                ref.setData(dict) { error in
                    if let error {
                        print("Data could not be saved: \(error).")
                        completion(false, error.localizedDescription)
                    } else {
                        print("Data saved successfully!")
                        completion(true,"")
                    }
                }
            }
        }
    }
    
    func likeUnlikePost(id: String, isLike : Bool = true, completion: @escaping (_ success: Bool,_ err: String) -> Void) {
        
        // Create Post on firebase
        Constants.firestoreRef.databaseAllPosts.document(id).updateData(
            ["likesCount" : isLike ? FieldValue.increment(Int64(1)) : FieldValue.increment(Int64(-1)),
             "likedIDs":  isLike ? FieldValue.arrayUnion([base.getUserId()]) : FieldValue.arrayRemove([base.getUserId()])
            ], completion: { error in
                if let error = error {
                    print("Data could not be saved: \(error).")
                    completion(false, error.localizedDescription)
                } else {
                    print(isLike ? "Post liked!" : "Post unliked!")
                    completion(true,"")
                }
            })
    }
    
    func upratePost(id: String, isUprate : Bool = true, completion: @escaping (_ success: Bool,_ err: String) -> Void) {
        // Create Post on firebase
        Constants.firestoreRef.databaseAllPosts.document(id).updateData(
            ["upratesCount" : isUprate ? FieldValue.increment(Int64(1)) : FieldValue.increment(Int64(-1)),
             "upratesIDs":  isUprate ? FieldValue.arrayUnion([base.getUserId()]) : FieldValue.arrayRemove([base.getUserId()])
            ], completion: { error in
                if let error = error {
                    print("Data could not be saved: \(error).")
                    completion(false, error.localizedDescription)
                } else {
                    print(isUprate ? "Post Uprated!" : "Post Down rated!")
                    completion(true,"")
                }
            })
    }
    
    func uploadFileTo(ref storageReference : StorageReference, data: Data, completion: @escaping ((_ success: Bool) -> Void), errorCompletion: @escaping ErrorType) {
        storageReference.putData(data, metadata: nil) { (storageMetaData, error) in
            if let error = error {
                print("Upload error: \(error.localizedDescription)")
                errorCompletion(error.localizedDescription)
            }
            print("File uploaded! Adding post.")
            completion(true)
        }
    }
    
    
    func addCommentToPost(id: String, params : dictionaryParameter, completion: @escaping (_ success: Bool,_ err: String) -> Void) {
        var dict = params
        let query = Constants.firestoreRef.databaseAllPosts.document(id).collection("comments").document()
        dict["id"] = query.documentID
        query.setData(dict, completion: { error in
            if let error = error {
                print("Data could not be saved: \(error).")
                completion(false, error.localizedDescription)
            } else {
                print("Comment added succsesfly")
                completion(true,"")
            }
        })
    }
    
    func downloadImage(from url: URL,completion: @escaping(_ image: UIImage?)-> Void)  {
        //        let img = UIImage(named: "img")
        print("Download Started")
        BaseClass().getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            completion((UIImage(data: data)))
        }
    }
    
    func updateUserProfile(id : String,_ dict: dictionaryParameter, completion: @escaping(_ status: Bool)-> Void) {
        Constants.firestoreRef.databaseUser.document(id).updateData(dict) { error in
            if let error = error {
                print("Data could not be saved: \(error).")
                completion(false)
            } else {
                print("Data updated successfully!")
                completion(true)
            }
        }
    }
    
    func getPostComments(id: String, completion: @escaping (_ comments: [Comment])-> Void, errorCompletion: @escaping ErrorType) {
        
        print("User ID:",id)
        let uid = id.trimmingCharacters(in: .whitespaces)
        Constants.firestoreRef.databaseAllPosts.document(uid).collection("comments").getDocuments(completion: { snaps, error in
            guard let snaps else {
                errorCompletion(error?.localizedDescription ?? AC.SomeThingWrong)
                return
            }
            var allComments = [Comment]()
            for snap in snaps.documents {
                let commentData = snap.data()
                do {
                    let comment = try FirebaseDecoder().decode(Comment.self, from: commentData)
                    allComments.append(comment)
                } catch let error {
                    print(error)
                    errorCompletion(error.localizedDescription)
                    return
                }
            }
            allComments.sort(by: {$0.timestamp ?? 1 > $1.timestamp ?? 0})
            
            completion(allComments)
            
        })
        
    }
    
    
    func getAllStories(completion: @escaping (_ stories: IGStories)-> Void, errorCompletion: @escaping ErrorType) {
        
        let myId = base.getUserId()
        Constants.firestoreRef.databaseAllStories.getDocuments(completion: { snaps, error in
            guard let snaps else {
                errorCompletion(error?.localizedDescription ?? AC.SomeThingWrong)
                return
            }
            
            var othersStories = [IGStory]()
            var myStories = [IGStory]()
            for snap in snaps.documents {
                let storyData = snap.data()
                do {
                    let story = try FirebaseDecoder().decode(IGStory.self, from: storyData)
                    story.snaps = story.snaps?.filter({$0.lastUpdated.addingDays() > Date().unixTimestamp})
                    story.snaps = story.snaps?.sorted(by: {$0.lastUpdated ?? 1 > $1.lastUpdated ?? 0})
                    if story.userId == myId {
                        myStories.append(story)
                    } else {
                        othersStories.append(story)
                    }
                } catch let error {
                    print(error)
                    errorCompletion(error.localizedDescription)
                    return
                }
            }
            myStories = myStories.filter({$0.snaps?.count ?? 0 > 0})
            othersStories = othersStories.filter({$0.snaps?.count ?? 0 > 0})
            let stories = IGStories(otherStories: othersStories, myStory: myStories)
            completion(stories)
        })
        
    }
    
    func getUserData(id: String, completion: @escaping (_ user: User)-> Void, errorCompletion: @escaping ErrorType) async {
        
        print("User ID:",id)
        let uid = id.trimmingCharacters(in: .whitespaces)
        do {
            let user = try await Constants.firestoreRef.databaseUser.document(uid).getDocument(as: User.self)
            completion(user)
        } catch let error {
            print(error)
            errorCompletion(error.localizedDescription)
        }
        
    }
    
    func getAllUprates(completion: @escaping (_ posts: [Post])-> Void, errorCompletion: @escaping ErrorType) {
        
        Constants.firestoreRef.databaseAllPosts.order(by: "upratesCount").whereField("upratesCount", isGreaterThan: 0).getDocuments(completion: { snaps, error in
            guard let snaps else {
                errorCompletion(error?.localizedDescription ?? AC.SomeThingWrong)
                return
            }
            var allPosts = [Post]()
            for snap in snaps.documents {
                let postData = snap.data()
                do {
                    let post = try FirebaseDecoder().decode(Post.self, from: postData)
                    allPosts.append(post)
                } catch let error {
                    print(error)
                    errorCompletion(error.localizedDescription)
                    return
                }
            }
            allPosts.sort(by: {$0.upratesCount ?? 1 > $1.upratesCount ?? 0})
            completion(allPosts)
            
        })
        
    }
    
    func getUserPosts(id: String, isVideos : Bool = false, completion: @escaping (_ posts: [Post])-> Void, errorCompletion: @escaping ErrorType) {
        
        print("User ID:",id)
        let uid = id.trimmingCharacters(in: .whitespaces)
        Constants.firestoreRef.databaseAllPosts.whereField("userId", isEqualTo: uid).whereField("isVideo", isEqualTo: isVideos).getDocuments(completion: { snaps, error in
            guard let snaps else {
                errorCompletion(error?.localizedDescription ?? AC.SomeThingWrong)
                return
            }
            var allPosts = [Post]()
            for snap in snaps.documents {
                let postData = snap.data()
                do {
                    let post = try FirebaseDecoder().decode(Post.self, from: postData)
                    allPosts.append(post)
                } catch let error {
                    print(error)
                    errorCompletion(error.localizedDescription)
                    return
                }
            }
            allPosts.sort(by: {$0.timestamp ?? 1 > $1.timestamp ?? 0})
            completion(allPosts)
            
        })
        
    }
    
    func getPostsOfSubscribedUsers(isVideos : Bool = false, completion: @escaping (_ posts: [Post])-> Void, errorCompletion: @escaping ErrorType) {
        
        var subscribedPosts = [Post]()
        
        //        var query =
        
        //        if let idsList = base.readUserData()?.subscribedList, idsList.count > 0 {
        //            query =  query.whereField("userId", in: idsList)
        //        }
        
        Constants.firestoreRef.databaseAllPosts.whereField("isVideo", isEqualTo: isVideos).getDocuments(completion: { snaps, error in
            guard let snaps else {
                errorCompletion(error?.localizedDescription ?? AC.SomeThingWrong)
                return
            }
            for snap in snaps.documents {
                let postData = snap.data()
                do {
                    let post = try FirebaseDecoder().decode(Post.self, from: postData)
                    subscribedPosts.append(post)
                } catch let error {
                    print(error)
                    errorCompletion(error.localizedDescription)
                    return
                }
            }
            subscribedPosts.sort(by: {$0.timestamp ?? 1 > $1.timestamp ?? 0})
            
            completion(subscribedPosts)
            
        })
        
    }
    
    func getAllPostsForNotSubscribed(isVideos : Bool = false, completion: @escaping (_ posts: [Post])-> Void, errorCompletion: @escaping ErrorType) {
        
        var allPosts = [Post]()
        
        var query = Constants.firestoreRef.databaseAllPosts.whereField("isVideo", isEqualTo: isVideos)
        
        if let idsList = base.readUserData()?.subscribedList, idsList.count > 0 {
            query =  query.whereField("userId", notIn: idsList)
        }
        
        query.getDocuments(completion: { snaps, error in
            guard let snaps else {
                errorCompletion(error?.localizedDescription ?? AC.SomeThingWrong)
                return
            }
            for snap in snaps.documents {
                let postData = snap.data()
                do {
                    let post = try FirebaseDecoder().decode(Post.self, from: postData)
                    allPosts.append(post)
                } catch let error {
                    print(error)
                    errorCompletion(error.localizedDescription)
                    return
                }
            }
            allPosts.sort(by: {$0.timestamp ?? 1 > $1.timestamp ?? 0})
            
            completion(allPosts)
            
        })
    }
    
    func subscribeUser(othersUserId: String, othersName: String, isAlreadySubscribed : Bool = false, completion: @escaping (_ status: Bool)-> Void, errorCompletion: @escaping ErrorType) {
        let myUser = base.readUserData()
        Task {
            await self.getUserData(id: othersUserId, completion: { user in
                let otherUser = user
                if otherUser.subscribersList == nil {
                    otherUser.subscribersList = [User]()
                    otherUser.subscribers = 0
                }
                if isAlreadySubscribed {
                    otherUser.subscribers = (otherUser.subscribers ?? 1) - 1
                    otherUser.subscribersList?.removeAll(where: { $0.id == myUser?.id })
                } else {
                    otherUser.subscribers = (otherUser.subscribers ?? 1) + 1
                    otherUser.subscribersList?.append(User(id: myUser?.id ?? "-1", name: myUser?.name ?? ""))
                }
                let othersDict = otherUser.asDict
                self.updateUserProfile(id: othersUserId, othersDict) { status in
                    if status {
                        print("Other user subscribers updated successfully!")
                        let myUserFB = myUser
                        
                        if (myUserFB?.subscribedList) == nil {
                            let list = [User]()
                            myUserFB?.subscribedList = list
                            myUserFB?.subscribed = 0
                        }
                        
                        if isAlreadySubscribed {
                            myUserFB?.subscribed = (myUserFB?.subscribed ?? 1) - 1
                            myUserFB?.subscribedList?.removeAll(where: {$0.id == othersUserId})
                        } else {
                            myUserFB?.subscribed = (myUserFB?.subscribed ?? 1) + 1
                            myUserFB?.subscribedList?.append(User(id: othersUserId, name: othersName))
                        }
                        let myId = myUser?.id ?? "-1"
                        let myDict = myUserFB!.asDict
                        self.updateUserProfile(id: myId, myDict) { status in
                            if status {
                                self.saveToDefauls(user: myUserFB!)
                                completion(true)
                            } else {
                                errorCompletion("Error subscribing user. Please try again.")
                            }
                        }
                    }
                }
            }, errorCompletion: { error in
                errorCompletion(error)
            })
        }
    }
    
    private func saveToDefauls(user: User) {
        self.base.saveUserToDefaults(user)
    }
}
    


