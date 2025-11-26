//
//  HomeVC.swift
//  SocialMediaApp
//
//  Created by Munib Hamza on 14/12/2022.
//

import UIKit
import BetterSegmentedControl
import CHTCollectionViewWaterfallLayout

class HomeVC: BaseClass {
    
    @IBOutlet weak var scrollVu: UIScrollView!
    @IBOutlet weak var storiesContainerVu: UIView!
    @IBOutlet weak var postCvLayout: CHTCollectionViewWaterfallLayout!
    @IBOutlet weak var storiesCV: UICollectionView!
    @IBOutlet weak var segmentControll: BetterSegmentedControl!
    @IBOutlet weak var postsCV: UICollectionView!
    
    private var viewModel: IGHomeViewModel = IGHomeViewModel()
    var popRecognizer: InteractivePopRecognizer?

    var fetchedAllPosts = false
    var fetchedAllVideoPosts = false
    var homePosts : [Post] = []
    var homeVideoPosts : [Post] = []
    var upratedPosts: [Post] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollVu.delegate = self
        setup()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.fetchAllUserStories()
        self.getPostsOfSubscribedUsers(isForVideos: segmentControll.index != 0)
    }
    
    func setup() {
        setInteractiveRecognizer()

        postsCV.delegate = self
        postsCV.dataSource = self
        storiesCV.delegate = self
        scrollVu.delegate = self
        storiesCV.dataSource = self
        let layout = storiesCV.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: 130, height: 180)
        setContentInsets()
        
        NotificationCenter.default.addObserver(self, selector: #selector(newPostAdded), name: .init("newPostAdded"), object: nil)

        postCvLayout.columnCount = 2
        postCvLayout.minimumColumnSpacing = 4
        segmentControll.setupSegmentWith(titles: ["Images","Videos","Seek"])
        
        postsCV.register(UINib(nibName: PostCell.id, bundle: nil), forCellWithReuseIdentifier: PostCell.id)
        storiesCV.register(UINib(nibName: StoryCell.id, bundle: nil), forCellWithReuseIdentifier: StoryCell.id)
    }
    
    private func setInteractiveRecognizer() {
        guard let controller = navigationController else { return }
        popRecognizer = InteractivePopRecognizer(controller: controller)
        controller.interactivePopGestureRecognizer?.delegate = popRecognizer
    }
    
    func fetchAllUpratedPost() {
        print("Fetching All Uprates")
        self.startLoading()
        NetworkCalls.shared.getAllUprates { uprates in
            self.stopLoading()
            self.upratedPosts = uprates
            DispatchQueue.main.async {
                self.postsCV.reloadData()
            }
        } errorCompletion: { error in
            self.stopLoading()
            Alerts.showAlertWithError(error)
        }
    }
    
    func fetchAllUserStories() {
        print("Fetching All Stories")
        self.startLoading()
        NetworkCalls.shared.getAllStories { stories in
            self.stopLoading()
            self.viewModel.stories = stories
            DispatchQueue.main.async {
                self.storiesCV.reloadData()
            }
        } errorCompletion: { error in
            self.stopLoading()
            Alerts.showAlertWithError(error)
        }
    }
    
    func getPostsOfSubscribedUsers(isForVideos : Bool) {
        print("Fetching User Subscribed Posts")
        self.startLoading()
        if isForVideos {
            fetchedAllVideoPosts = false
        } else {
            self.fetchedAllPosts = false
        }
        NetworkCalls.shared.getPostsOfSubscribedUsers(isVideos: isForVideos, completion: { posts in
            if isForVideos {
                self.homeVideoPosts = posts
            } else {
                self.homePosts = posts
            }
            if posts.count == 0 {
                self.getPostsOfAllUsers(isForVideos: isForVideos)
            }
            DispatchQueue.main.async {
                self.stopLoading()
                self.postsCV.reloadData()
            }
        }, errorCompletion: { error in
            self.stopLoading()
            Alerts.showAlertWithError(error)
        })
    }
    
    func getPostsOfAllUsers(isForVideos : Bool) {
        print("Fetching Home Posts")
        self.startLoading()
        if isForVideos {
            self.fetchedAllPosts = true
        } else {
            fetchedAllVideoPosts = true
        }
        NetworkCalls.shared.getAllPostsForNotSubscribed(isVideos: isForVideos, completion: { posts in
            if isForVideos {
                self.homeVideoPosts.append(contentsOf: posts)
            } else {
                self.homePosts.append(contentsOf: posts)
            }
            DispatchQueue.main.async {
                self.stopLoading()
                self.postsCV.reloadData()
            }
        }, errorCompletion: { error in
            self.stopLoading()
            Alerts.showAlertWithError(error)
        })
    }
    
    func addMyStory() {
        DispatchQueue.main.async {
            let typeVC = self.getRef(storyboard: .Main, identifier: SelectTypeVC.id) as! SelectTypeVC
            typeVC.mediaSelected = { image, video in
                typeVC.dismiss(animated: true) {
                    let vc = self.getRef(storyboard: .Main, identifier: AddImageVC.id) as! AddImageVC
                    vc.isForStories = true
                    if let video {
                        print("Video selected", video.url)
                        vc.selectedVideo = video
                        self.present(vc: vc)
                    } else if let image {
                        print("Image selected")
                        vc.selectedImage = image
                        self.present(vc: vc)
                    }
                }
            }
            typeVC.modalPresentationStyle = .overFullScreen
            self.present(vc: typeVC)
        }
    }
    
    @IBAction func segmentChanged(_ sender: BetterSegmentedControl) {
        let index = sender.index
        switch index {
        case 0:
            getPostsOfSubscribedUsers(isForVideos: false)
        case 1:
            getPostsOfSubscribedUsers(isForVideos: true)
        default:
            fetchAllUpratedPost()
        }
        print("Segement changed",sender.index)
        // Vibrate phone
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()

    }
    
    
}

extension HomeVC {
    @objc func newPostAdded() {
        self.viewWillAppear(true)
//        self.getPostsOfSubscribedUsers()
    }
}

extension HomeVC : UICollectionViewDelegate, UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == storiesCV {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StoryCell.reuseIdentifier,for: indexPath) as? StoryCell else { fatalError() }
            cell.plusImg.isHidden = indexPath.row != 0
            cell.addStoryBtn.isHidden = indexPath.row != 0

            if indexPath.row == 0, viewModel.stories?.myStory.count ?? 0 == 0 {
                cell.nameLbl.text = "Add new story"
                cell.storyImgVu.image = UIImage(named: "gradientImg")
                cell.imgVu.downloadImageFromRefWithoutCache(ref: getProfileUrl(), placeholder: "placeholder")
                cell.addStoryPressed = {
                    self.addMyStory()
                }
            } else {
                let story = viewModel.cellForItemAt(indexPath: indexPath)
                
                if let first = story?.snaps?.first {
                    if first.mimeType == "image" {
                        cell.storyImgVu.sd_setImage(with: (URL(string: story?.snaps?.first?.url ?? "")), placeholderImage: UIImage(named: "placeholder"))
                    } else {
                        getThumbnailImageFromVideoUrl(urlStr: first.url) { image in
                            DispatchQueue.main.async {
                                cell.storyImgVu.image = image
                            }
                            
                        }
                    }
                }
                cell.story = story
            }
            return cell
            
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostCell.id, for: indexPath) as! PostCell
            var post = Post()
            cell.imgVu.image = UIImage(named: "placeholder")

            if segmentControll.index == 0 {
                guard homePosts.count > 0 else {return cell}
                post = homePosts[indexPath.row]
            } else if segmentControll.index == 1 {
                guard homeVideoPosts.count > 0 else {return cell}
                post = homeVideoPosts[indexPath.row]
            } else {
                guard upratedPosts.count > 0 else {return cell}
                post = upratedPosts[indexPath.row]
            }
            cell.setUpWith(post: post)
            cell.likeBtn.tag = indexPath.row
            cell.likePressed = {
                if self.segmentControll.index == 0 {
                    cell.likeOrUnlikePost(post: self.homePosts[indexPath.row])
                } else if self.segmentControll.index == 1 {
                    cell.likeOrUnlikePost(post: self.homeVideoPosts[indexPath.row])
                } else {
                    cell.likeOrUnlikePost(post: self.upratedPosts[indexPath.row])
                }
            }
            
            cell.postLiked = { [self] isAlreadyLiked in
                if isAlreadyLiked {
                    post.likedIDs?.removeAll(where: {$0 == getUserId()})
                } else {
                    post.likedIDs?.append(getUserId())
                }
            }
            
            cell.upratePressed = {
                if self.segmentControll.index == 0 {
                    cell.upratePost(post: self.homePosts[indexPath.row])
                } else if self.segmentControll.index == 1 {
                    cell.upratePost(post: self.homeVideoPosts[indexPath.row])
                } else {
                    cell.upratePost(post: self.upratedPosts[indexPath.row])
                }
            }
            
            cell.postUprated = { [self] isAlreadyUprated in
                if isAlreadyUprated {
                    post.upratesIDs?.removeAll(where: {$0 == getUserId()})
                    if segmentControll.index == 2 {
                        if post.upratesIDs?.count == 0 {
                            collectionView.deleteItems(at: [indexPath])
                            upratedPosts.remove(at: indexPath.item)
                        }
                    }
                } else {
                    post.upratesIDs?.append(getUserId())
                }
            }
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == postsCV {
            if segmentControll.index == 0 {
                return homePosts.count
            } else if segmentControll.index == 1 {
                return homeVideoPosts.count
            } else {
                return upratedPosts.count
            }
        } else {
            return viewModel.numberOfItemsInSection(section)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView != postsCV {
            if indexPath.row == 0 {
                DispatchQueue.main.async {
                    if let stories = self.viewModel.getStories(),
                       stories.myStory.count > 0, stories.myStory[0].snaps?.count ?? 0 > 0 {
                        let storyPreviewScene = IGStoryPreviewController.init(stories: stories.myStory, handPickedStoryIndex:  indexPath.row, handPickedSnapIndex: 0)
                        self.present(storyPreviewScene, animated: true, completion: nil)
                    } else {
                        self.addMyStory()
                    }
                }
            } else {
                isDeleteSnapEnabled = false
                DispatchQueue.main.async {
                    if let stories = self.viewModel.getStories(), let stories_copy = try? stories.copy().otherStories {
                        let storyPreviewScene = IGStoryPreviewController.init(stories: stories_copy, handPickedStoryIndex:  indexPath.row-1, handPickedSnapIndex: 0)
                        self.present(storyPreviewScene, animated: true, completion: nil)
                    }
                }
            }
            
        } else {
            let vc = getRef(storyboard: .Main, identifier: CommentsVC.id) as! CommentsVC
            if segmentControll.index == 0 {
                vc.postDetails = homePosts[indexPath.row]
                vc.isVideoPost = homePosts[indexPath.row].isVideo ?? false
            } else if segmentControll.index == 1 {
                vc.postDetails = homeVideoPosts[indexPath.row]
                vc.isVideoPost = homeVideoPosts[indexPath.row].isVideo ?? false
            } else {
                vc.postDetails = upratedPosts[indexPath.row]
                vc.isVideoPost = upratedPosts[indexPath.row].isVideo ?? false
            }
            push(vc: vc)
        }
    }
    
//    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        if let _ = cell as? PostCell {
//
//            if segmentControll.index == 0 {
//                if indexPath.item > 0, indexPath.item == (homePosts.count - 2) || indexPath.item == (homePosts.count - 1), fetchedAllPosts == false {
//                    getPostsOfAllUsers(isForVideos: false)
//                }
//            } else if segmentControll.index == 1 {
//                if indexPath.item > 0, indexPath.item == (homeVideoPosts.count - 1) || indexPath.item == (homeVideoPosts.count - 2), fetchedAllVideoPosts == false {
//                    getPostsOfAllUsers(isForVideos: true)
//                }
//            }
//        }
//    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == storiesCV {
            return CGSize(width: 150, height: 220)
        } else {
            if segmentControll.index == 0 {
                var height = homePosts[indexPath.row].height ?? 0
                let width = homePosts[indexPath.row].width ?? 0
                if height < 100 {
                    height = CGFloat.random(in: 300..<400)
                }
                height = height + 300 // for buttons below cell
                return CGSize(width: width, height: height)
            } else if segmentControll.index == 1 {
                var height = homeVideoPosts[indexPath.row].height ?? 0
                let width = homeVideoPosts[indexPath.row].width ?? 0
                if height < 100 {
                    height = CGFloat.random(in: 300..<400)
                }
                height = height + 100 // for buttons below cell
                return CGSize(width: width, height: height)
            } else {
                let post = upratedPosts[indexPath.row]
                var height = post.height ?? 0
                let width = post.width ?? 0
                if height < 100 {
                    height = CGFloat.random(in: 300..<400)
                }
                height = height + ((post.isVideo ?? false) ? 100 : 300) // for buttons below cell
                return CGSize(width: width, height: height)
            }
        }
    }
    
}

extension HomeVC : UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if postsCV.contentOffset.y < 260 {
            if postsCV.contentOffset.y > 0 {
                scrollVu.setContentOffset(postsCV.contentOffset, animated: false)
                
            } else {
                scrollVu.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: false)
            }
        } else {
            scrollVu.setContentOffset(CGPoint(x: 0.0, y: 260), animated: false)
        }
    }
    
    func setContentInsets () {
        postsCV.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 300, right: 0)
    }
    
}
