import Foundation
import FirebaseFirestore

// By conforming to Identifiable, we can use DBUser directly in SwiftUI lists and ForEach loops.
struct DBUser: Codable, Identifiable {
    // We explicitly map the `id` property to `userId` for SwiftUI's benefit.
    var id: String { userId }
    
    @DocumentID var documentId: String?
    let userId: String
    let email: String?
    var name: String?
    var birthDate: Date?
    var bio: String?
    var profileImageURL: String?
    let dateCreated: Date?
    
    // We need CodingKeys to ensure our custom `id` property doesn't interfere
    // with the encoding/decoding of the stored properties.
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
    
    /// Fetches multiple user profiles based on an array of user IDs.
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
