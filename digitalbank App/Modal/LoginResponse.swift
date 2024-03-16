import Foundation
struct LoginResponse : Decodable {
    var token: String?
}
struct LoginResponseError : Decodable {
    var error: String?
}
