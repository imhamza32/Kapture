//
//  UsersListVC.swift
//  SocialMediaApp
//
//  Created by Munib Hamza on 14/01/2023.
//

import UIKit

class UsersListVC: BaseClass {

    @IBOutlet weak var tblVu: UITableView!
    @IBOutlet weak var topLbl: UILabel!
    
    var users : [User?] = []
    var topLblText = ""
    var isFromMyProfile = false
    var isSubscribedView = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblVu.delegate = self
        tblVu.dataSource = self
        tblVu.register(UINib(nibName: UserCell.id, bundle: nil), forCellReuseIdentifier: UserCell.id)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        topLbl.text = topLblText
    }
    
    @IBAction func backPressed(_ sender: Any) {
        self.goBack()
    }
}

extension UsersListVC : UserSubscribed {
    func userSubscribed(user: User?, isSub: Bool) {
        if isSub {
            self.users.append(user)
        }else {
            self.users.removeAll(where: {$0?.id == user?.id})
        }
        
        DispatchQueue.main.async {
            self.tblVu.reloadData()
        }
    }
}

extension UsersListVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserCell.id, for: indexPath) as! UserCell
        let user = users[indexPath.row]
        cell.nameLbl.text = user?.name
        cell.imgVu.downloadImageFromRef(ref: getProfilePicRef(of: user?.id ?? ""), placeholder: "user")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let id = users[indexPath.row]?.id else {
            Alerts.showOKAlertWithMessage("Can not find this user.")
            return
        }
        guard id != getUserId() else {return}
        let vc = getRef(identifier: OthersProfileVC.id) as! OthersProfileVC
        vc.userId = id
        if isFromMyProfile && isSubscribedView {
            vc.subscribedDelegate = self
        }
        self.push(vc: vc)
    }
}
