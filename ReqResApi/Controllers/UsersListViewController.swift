//
//  UsersListViewController.swift
//  ReqResApi
//
//  Created by Шахова Анастасия on 11.11.2023.
//

import Foundation
import UIKit

protocol NewUserViewControllerDelegate {
    func createUser(user: User)
}

final class UsersListViewController: UITableViewController {
    
    private var users = [User]()
    private let networkManager = NetworkManager.shared
    private var spinnerView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80
        fetchUsers()
        showSpiner(in: tableView)
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showUser" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let user = users[indexPath.row]
            
            let userVC = segue.destination as? UserViewController
            userVC?.user = user
        } else if segue.identifier == "newUser" {
            let navigationVC = segue.destination as? UINavigationController
            let newUserVC = navigationVC?.topViewController as? NewUserViewController
            newUserVC?.delegate = self
            
        }
    }
    
    private func showAlert(withError networkError: NetworkError) {
        let alert = UIAlertController(title: networkError.title, message: nil, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        present(alert,animated: true)
    }
    
    private func showSpiner(in view: UIView) {
        spinnerView.style = .large
        spinnerView.startAnimating()
        spinnerView.hidesWhenStopped = true
        spinnerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spinnerView)
        
        NSLayoutConstraint.activate([
            spinnerView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            spinnerView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
        ])
    }
    
}

//MARK: - Networking
extension UsersListViewController {
    private func fetchUsers() {
        networkManager.fetchUsers { [weak self] result in
            self?.spinnerView.stopAnimating()
            switch result {
            case .success(let users):
                self?.users = users
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                self?.showAlert(withError: error)
            }
            self?.tableView.reloadData()
        }
    }
    
    private func post(user: User) {
        networkManager.postUser(user) { [weak self] result in
            switch result {
            case .success(let postUserQuery):
                print("\(postUserQuery) created")
                self?.users.append(User(postUserQUery: postUserQuery))
                self?.tableView.reloadData()
            case .failure(let error):
                print("Error in post user: \(error)")
                
            }
        }
    }
    
    private func delete(id: Int, indexPath: IndexPath) {
//        networkManager.deleteUserWith(id) { [weak self] result  in
//            if result {
//                self?.users.remove(at: indexPath.row)
//                self?.tableView.deleteRows(at: [indexPath], with: .automatic)
//            } else {
//                self?.showAlert(withError: .deletingError)
//            }
//        }
        
        Task {
            if try await networkManager.deleteUserWith(id) {
                users.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            } else {
                showAlert(withError: .deletingError)
            }
        }
    }
}

//MARK: - UITableViewDataSource
extension UsersListViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? UserTableViewCell else { return UITableViewCell() }
        
        cell.configure(with: users[indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let user = users[indexPath.row]
            delete(id: user.id, indexPath: indexPath)
        }
    }
}

//MARK: - NewUserViewCOntrollerDelegate
extension UsersListViewController: NewUserViewControllerDelegate {
    func createUser(user: User) {
        post(user: user)
    }
}

