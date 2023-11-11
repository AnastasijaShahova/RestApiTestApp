//
//  UserViewController.swift
//  ReqResApi
//
//  Created by Шахова Анастасия on 11.11.2023.
//

import UIKit
import Kingfisher

final class UserViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var photo: UIImageView!
    
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        composeUser(user)
    }
    
    private func composeUser(_ user: User) {
        nameLabel.text = "\(user.firstName) \(user.lastName)"
        photo.kf.setImage(with: user.avatar)
    }

}
