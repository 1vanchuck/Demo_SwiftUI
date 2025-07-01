import Foundation
import FirebaseStorage
import UIKit

final class StorageManager {
    
    static let shared = StorageManager()
    private init() {}
    
    private let storage = Storage.storage().reference()
    
    // A reference to the Cloud Storage folder for user profile pictures.
    private var profilePicsReference: StorageReference {
        storage.child("profile_pics")
    }
    
    // A reference to the Cloud Storage folder for event cover images.
    private var eventImagesReference: StorageReference {
        storage.child("event_images")
    }
    
    func uploadProfilePic(image: UIImage, forUserID userID: String) async throws -> URL {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { throw URLError(.cannotCreateFile) }
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        let fileRef = profilePicsReference.child("\(userID).jpg")
        _ = try await fileRef.putDataAsync(imageData, metadata: metadata)
        return try await fileRef.downloadURL()
    }
    
    /// Uploads an image for a specific event.
    func uploadEventImage(image: UIImage, eventId: String) async throws -> URL {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { throw URLError(.cannotCreateFile) }
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        let fileRef = eventImagesReference.child("\(eventId).jpg")
        _ = try await fileRef.putDataAsync(imageData, metadata: metadata)
        return try await fileRef.downloadURL()
    }
    
    func deleteEventImage(eventId: String) async throws {
        let fileRef = eventImagesReference.child("\(eventId).jpg")
        try await fileRef.delete()
    }
}
