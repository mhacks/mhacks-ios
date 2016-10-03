//
//  Floor.swift
//  MHacks
//
//  Created by Manav Gabhawala on 9/29/16.
//  Copyright © 2016 MHacks. All rights reserved.
//

import Foundation
import UIKit

final class Floor: SerializableElementWithIdentifier
{
    let ID: String
    var name: String
    var imageURL: String
    var index: Int
    var offsetFraction: Double
    var aspectRatio: Double
    var fileLocation: String?
    private var imageCache: UIImage? = nil
    
    init(ID: String, name: String, imageURL: String, index: Int, offsetFraction: Double, aspectRatio: Double, fileLocation: String?)
    {
        self.ID = ID
        self.name = name
        self.imageURL = imageURL
        self.index = index
        self.offsetFraction = offsetFraction
        self.aspectRatio = aspectRatio
        self.fileLocation = fileLocation
    }
    
    
    /// Call this function to get the image from a floor. This function handles all the caching and under the hood optimizations and so may call your completion almost immediately.
    ///
    /// - Parameter completion: A callback which accepts the image for this floor.
    func retrieveImage(_ completion: @escaping (UIImage) -> Void)
    {
        let internalCompletion = { (image: UIImage) in
            self.imageCache = image
            completion(image)
        }
        if let image = imageCache
        {
            internalCompletion(image)
            return
        }
        if let image = imageFromFileLocation()
        {
            internalCompletion(image)
            return
        }
        guard let URL = URL(string: imageURL)
        else {
            assertionFailure("Could not resolve URL \(imageURL) from server")
            return
        }
        
        let task = URLSession.shared.downloadTask(with: URL) { fileURL, response, error in
            guard error == nil, let fileURL = fileURL
            else {
                NotificationCenter.default.post(name: APIManager.FailureNotification, object: error?.localizedDescription ?? "Failed to download floor \(self.name)")
                return
            }
            
            let newFileLocation = container.appendingPathComponent(URL.lastPathComponent)
            _ = try? FileManager.default.removeItem(at: newFileLocation)
            do {
                try FileManager.default.copyItem(at: fileURL, to: newFileLocation)
                self.fileLocation = newFileLocation.path
                if let image = self.imageFromFileLocation()
                {
                    internalCompletion(image)
                }
            }
            catch
            {
                NotificationCenter.default.post(name: APIManager.FailureNotification, object: error.localizedDescription)
            }
        }
        task.resume()
    }
    private func imageFromFileLocation() -> UIImage?
    {
        guard let location = fileLocation
        else
        {
            return nil
        }
        return UIImage(contentsOfFile: location)
    }
}
extension Floor
{
    private static let nameKey = "name"
    private static let imageURLKey = "image"
    private static let indexKey = "index"
    private static let offsetFractionKey = "offset_fraction"
    private static let aspectRatioKey = "aspect_ratio"
    private static let fileLocationKey = "file"
    
    
    convenience init?(_ serializedRepresentation: SerializedRepresentation) {
        guard let id = serializedRepresentation[Floor.idKey] as? String, let name = serializedRepresentation[Floor.nameKey] as? String, let imageURL = serializedRepresentation[Floor.imageURLKey] as? String, let index = serializedRepresentation[Floor.indexKey] as? Int, let offsetFraction = serializedRepresentation[Floor.offsetFractionKey] as? Double, let aspectRatio = serializedRepresentation[Floor.aspectRatioKey] as? Double
            else { return nil }
        
        self.init(ID: id, name: name, imageURL: imageURL, index: index, offsetFraction: offsetFraction, aspectRatio: aspectRatio, fileLocation: serializedRepresentation[Floor.fileLocationKey] as? String)
    }
    func toSerializedRepresentation() -> NSDictionary
    {
        var dict: [String: Any] = [Floor.idKey: ID, Floor.nameKey: name, Floor.imageURLKey: imageURL, Floor.indexKey: index, Floor.offsetFractionKey : offsetFraction, Floor.aspectRatioKey: aspectRatio]
        if let file = fileLocation
        {
            dict[Floor.fileLocationKey] = file
        }
        return dict as NSDictionary
    }
}
func <(lhs: Floor, rhs: Floor) -> Bool {
    return lhs.index < rhs.index
}
