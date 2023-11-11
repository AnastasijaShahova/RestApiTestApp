//
//  NewUserViewController.swift
//  ReqResApi
//
//  Created by Шахова Анастасия on 11.11.2023.
//

import UIKit

final class NewUserViewController: UIViewController {

    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var firstNameTF: UITextField!
    
    var delegate: NewUserViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @IBAction func doneTapped(_ sender: UIBarButtonItem) {
        
        let user = User(id: 0, firstName: firstNameTF.text ?? "", lastName: lastNameTF.text ?? "")
        delegate?.createUser(user: user)
        dismiss(animated: true)
    }
}

