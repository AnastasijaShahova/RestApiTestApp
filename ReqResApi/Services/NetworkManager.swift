//
//  NetworkManager.swift
//  ReqResApi
//
//  Created by Шахова Анастасия on 11.11.2023.
//

import Foundation
import Alamofire

final class NetworkManager {
    
    static let shared = NetworkManager()
    
    private init() {}
    
    func fetchUsers(completion: @escaping(Result<[User], AFError>) -> ()) {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        AF.request(Link.allUsers.url).validate().responseDecodable(of: UsersQuery.self, decoder: decoder) { dataResponse in
            switch dataResponse.result {
                case .success(let userQuery):
                    completion(.success(userQuery.data))
                case .failure(let error):
                    completion(.failure(error))
            }
        }
    }
    
    func postUser(_ user: User, completion: @escaping(Result<PostUserQuery, AFError>) -> ()) {

        let postUserParametrs = PostUserQuery(firstName: user.firstName, lastName: user.lastName)
        
        AF.request(Link.singleUser.url, method: .post, parameters: postUserParametrs).validate().responseDecodable(of: PostUserQuery.self) { dataResponse in
            switch dataResponse.result {
                case .success(let postUserQuery):
                    completion(.success(postUserQuery))
                case .failure(let error):
                    completion(.failure(error))
            }
        }
    }
    
    func deleteUserWith(_ id: Int, completion: @escaping(Bool) -> ()) {
        let userURL = Link.singleUser.url.appendingPathComponent("\(id)")
        
        AF.request(userURL, method: .delete).validate(statusCode: [204]).response { dataResponse in
            switch dataResponse.result {
                case .success( _):
                    completion(true)
                case .failure(_):
                    completion(false)
            }
        }
    }
    
//    func deleteUserWith(_ id: Int) async throws -> Bool {
//        let userURL = Link.singleUser.url.appendingPathComponent("\(id)")
//        var request = URLRequest(url: userURL)
//        request.httpMethod = "DELETE"
//
//        let (_, response) =  try await URLSession.shared.data(for: request)
//
//        if let response = response as? HTTPURLResponse {
//            return response.statusCode == 204
//        }
//
//        return false
//    }
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
