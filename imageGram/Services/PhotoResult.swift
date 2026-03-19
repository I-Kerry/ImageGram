
import Foundation

struct PhotoResult: Codable {
    let id: String
    let width: Int
    let height: Int
    let date: String?
    let description: String?
    let urls: UrlsResult
    let likedByUsers: Bool
    let likes: Int
    
    private enum CodingKeys: String, CodingKey {
        case id
        case date = "created_at"
        case width
        case height
        case description
        case urls
        case likedByUsers = "liked_by_user"
        case likes
    }
}

struct UrlsResult: Codable {
    let thumbUrl: String
    let largeUrl: String
    
    private enum CodingKeys: String, CodingKey {
        case thumbUrl = "thumb"
        case largeUrl = "full"
    }
}

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}
