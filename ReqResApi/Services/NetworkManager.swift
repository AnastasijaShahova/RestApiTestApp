//
//  NetworkManager.swift
//  ReqResApi
//
//  Created by Шахова Анастасия on 11.11.2023.
//

import Foundation

enum NetworkError: Error {
    case decodingError
    case noData
    case noUsers
    case deletingError
    
    var title: String {
        switch self {
            case .decodingError:
                return "Cant decode received data"
            case .noData:
                return "Cant fetch data at all"
            case .noUsers:
                return "No users got from Api"
            case .deletingError:
                return "Cant delete user "
        }
    }
}

final class NetworkManager {
    
    static let shared = NetworkManager()
    
    private init() {}
    
    func fetchAvatar(from url: URL, completion: @escaping(Data) -> ()) {
        
        DispatchQueue.global().async {
            guard let imageData = try? Data(contentsOf: url) else { return }
            
            DispatchQueue.main.async {
                completion(imageData)
            }
        }
    }
    
    func fetchUsers(completion: @escaping(Result<[User], NetworkError>) -> ()) {
        URLSession.shared.dataTask(with: Link.allUsers.url) { data, response, error in
            guard let data = data, let response = response as? HTTPURLResponse else {
                print(error?.localizedDescription ?? "No error")
                sendFailure(with: .noData)
                return
            }
            
            if (200...299).contains(response.statusCode) {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                do {
                    let usersQuery = try decoder.decode(UsersQuery.self, from: data)
                    DispatchQueue.main.async {
                        if usersQuery.data.count == 0 {
                            sendFailure(with: .noUsers)
                            return
                        }
                        completion(.success(usersQuery.data))
                    }
                   
                } catch {
                    sendFailure(with: .decodingError)
                }

            }
            
            func sendFailure(with error: NetworkError) {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
                               
        }.resume()
    }
    
    func postUser(_ user: User, completion: @escaping(Result<PostUserQuery, NetworkError>) -> ()) {
        var request = URLRequest(url: Link.singleUser.url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let userQuery = PostUserQuery(firstName: user.firstName, lastName: user.lastName)
        
        let jsonData = try? JSONEncoder().encode(userQuery)
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data else { return  }
            
            if let postUserQuery = try? JSONDecoder().decode(PostUserQuery.self, from: data) {
                DispatchQueue.main.async {
                    completion(.success(postUserQuery))
                }
            } else {
                completion(.failure(.decodingError))
            }
        }.resume()
    }
    
    func deleteUserWith(_ id: Int, completion: @escaping(Bool) -> ()) {
        let userURL = Link.singleUser.url.appendingPathComponent("\(id)")
        var request = URLRequest(url: userURL)
        request.httpMethod = "DELETE"
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let response = response as? HTTPURLResponse {
                DispatchQueue.main.async {
                    completion(response.statusCode == 204)
                }
            }
        }.resume()
    }
    
    func deleteUserWith(_ id: Int) async throws -> Bool {
        let userURL = Link.singleUser.url.appendingPathComponent("\(id)")
        var request = URLRequest(url: userURL)
        request.httpMethod = "DELETE"
        
        let (_, response) =  try await URLSession.shared.data(for: request)
        
        if let response = response as? HTTPURLResponse {
            return response.statusCode == 204
        }
        
        return false
    }
}

// MARK: - Link
extension NetworkManager {
    enum Link {
        case allUsers
        case singleUser
        case withNoData
        case withDecodingError
        case withNoUsers
        
        var url: URL {
            switch self {
            case.allUsers:
                return URL(string: "https://reqres.in/api/users/?delay=2")!
            case .singleUser:
                return URL(string: "https://reqres.in/api/users/")!
            case .withNoData:
                return URL(string: "https://reqres.int/api/users")!
            case .withDecodingError:
                return URL(string: "https://reqres.in/api/users/3?delay=2")!
            case .withNoUsers:
                return URL(string: "https://reqres.in/api/users/?delay=2&page=3")!
               
            }
        }
    }
}
