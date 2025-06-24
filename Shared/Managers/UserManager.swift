import Foundation
import FirebaseFirestore

// ИЗМЕНЕНИЕ: Добавляем соответствие протоколу Identifiable
struct DBUser: Codable, Identifiable {
    // Явно указываем, что свойство 'id' будет нашим идентификатором
    // Оно совпадает с userId, что идеально для SwiftUI
    var id: String { userId }
    
    @DocumentID var documentId: String?
    let userId: String
    let email: String?
    var name: String?
    var birthDate: Date?
    var bio: String?
    var profileImageURL: String?
    let dateCreated: Date?
    
    // Добавляем CodingKeys, чтобы @DocumentID не конфликтовал с нашим 'id'
    enum CodingKeys: String, CodingKey {
        case documentId
        case userId
        case email
        case name
        case birthDate
        case bio
        case profileImageURL
        case dateCreated
    }
    
    init(auth: AuthDataResultModel) {
        self.userId = auth.uid
        self.email = auth.email
        self.name = nil
        self.birthDate = nil
        self.bio = nil
        self.profileImageURL = nil
        self.dateCreated = Date()
    }
}


final class UserManager {
    
    static let shared = UserManager()
    private init() {}
    
    private let db = Firestore.firestore(database: "partyapp")
    
    private func userDocument(userId: String) -> DocumentReference {
        db.collection("users").document(userId)
    }
    
    func fetchOrCreateUser(auth: AuthDataResultModel) async throws -> DBUser {
        let docRef = userDocument(userId: auth.uid)
        let snapshot = try await docRef.getDocument()
        
        if snapshot.exists, let user = try? snapshot.data(as: DBUser.self) {
            return user
        } else {
            let newUser = DBUser(auth: auth)
            try docRef.setData(from: newUser)
            return newUser
        }
    }
    
    func getUser(userId: String) async throws -> DBUser {
        try await userDocument(userId: userId).getDocument(as: DBUser.self)
    }
    
    // Новая функция для загрузки нескольких пользователей по их ID
    func fetchUsers(withIDs uids: [String]) async throws -> [DBUser] {
        if uids.isEmpty { return [] }
        
        let snapshot = try await db.collection("users")
            .whereField("userId", in: uids)
            .getDocuments()
        
        return try snapshot.documents.compactMap { try? $0.data(as: DBUser.self) }
    }
    
    func updateUserNameAndBirthDate(userId: String, name: String, birthDate: Date) async throws {
        let data: [String: Any] = ["name": name, "birthDate": birthDate]
        try await userDocument(userId: userId).updateData(data)
    }
    
    func updateUserProfileImage(userId: String, url: String) async throws {
        let data: [String: Any] = [ "profileImageURL": url ]
        try await userDocument(userId: userId).updateData(data)
    }
}
