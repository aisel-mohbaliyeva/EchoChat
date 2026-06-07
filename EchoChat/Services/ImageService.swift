import Foundation
import FirebaseStorage
import SwiftUI
import PhotosUI

final class ImageService {
    private let storage = Storage.storage().reference()
    
    func uploadImage(_ data: Data, path: String) async throws -> String {
        let ref = storage.child(path)
        _ = try await ref.putDataAsync(data)
        let url = try await ref.downloadURL()
        return url.absoluteString
    }
    
    func loadImage(from item: PhotosPickerItem?) async -> Data? {
        guard let item else { return nil }
        return try? await item.loadTransferable(type: Data.self)
    }
}
