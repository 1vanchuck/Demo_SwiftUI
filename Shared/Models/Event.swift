import Foundation
import FirebaseFirestore

enum RSVPStatus: String, Codable {
    case going, maybe, cantGo, pending
}

struct Event: Codable, Identifiable, Hashable {
    @DocumentID var id: String?
    
    var title: String
    var eventDate: Date
    var locationName: String
    var coordinates: GeoPoint?
    var descriptionText: String?
    var imageURL: String?
    let creatorId: String
    var attendees: [String: RSVPStatus]
    let dateCreated: Date
    var tags: [String]?
    var participantLimit: Int?
    
    init(title: String, eventDate: Date, locationName: String, creatorId: String) {
        self.title = title
        self.eventDate = eventDate
        self.locationName = locationName
        self.creatorId = creatorId
        self.attendees = [creatorId: .going]
        self.dateCreated = Date()
    }
}
