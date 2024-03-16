import Foundation
struct LoginResponse : Decodable {
    var authToken: String?
}
struct LoginResponseError : Decodable {
    var error: String?
}
