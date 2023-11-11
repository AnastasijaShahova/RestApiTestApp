//
//  UserTableViewCell.swift
//  ReqResApi
//
//  Created by Шахова Анастасия on 11.11.2023.
//

import UIKit
import Kingfisher

class UserTableViewCell: UITableViewCell {

    @IBOutlet weak var photo: UIImageView! {
        didSet {
            photo.layer.cornerRadius = photo.frame.width / 5
        }
    }
    @IBOutlet weak var nameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(with user: User) {
        nameLabel.text = "\(user.firstName) \(user.lastName)"
        if user.avatar != nil {
            photo.kf.setImage(with: user.avatar)
        } else {
            photo.image = UIImage(systemName: "person.crop.circle")
        }
    }

}
