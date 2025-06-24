import Foundation
import FirebaseStorage
import UIKit

final class StorageManager {
    
    static let shared = StorageManager()
    private init() {}
    
    private let storage = Storage.storage().reference()
    
    // Ссылка на папку с аватарами пользователей
    private var profilePicsReference: StorageReference {
        storage.child("profile_pics")
    }
    
    // НОВАЯ ССЫЛКА на папку с картинками ивентов
    private var eventImagesReference: StorageReference {
        storage.child("event_images")
    }
    
    // Старая функция для загрузки аватара
    func uploadProfilePic(image: UIImage, forUserID userID: String) async throws -> URL {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { throw URLError(.cannotCreateFile) }
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        let fileRef = profilePicsReference.child("\(userID).jpg")
        _ = try await fileRef.putDataAsync(imageData, metadata: metadata)
        return try await fileRef.downloadURL()
    }
    
    // НОВАЯ ФУНКЦИЯ для загрузки картинки ивента
    func uploadEventImage(image: UIImage, eventId: String) async throws -> URL {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { throw URLError(.cannotCreateFile) }
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        // Генерируем уникальное имя файла для картинки ивента
        let fileRef = eventImagesReference.child("\(eventId).jpg")
        _ = try await fileRef.putDataAsync(imageData, metadata: metadata)
        return try await fileRef.downloadURL()
    }
    
    func deleteEventImage(eventId: String) async throws {
        let fileRef = eventImagesReference.child("\(eventId).jpg")
        try await fileRef.delete()
    }
}
