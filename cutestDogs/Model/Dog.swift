//
//  Dog.swift
//  cutestDogs
//
//  Created by Бадый Шагаалан on 19.12.2019.
//  Copyright © 2019 badyi. All rights reserved.
//

import UIKit
import ResourceNetworking

class ServerDog {
    let breed : String
    let subBreed : String
    
    init (breed: String, subBreed: String) {
        self.breed = breed
        self.subBreed = subBreed
    }
}

protocol DogViewDelegate {
    func iconDidLoaded(for dog: DogView)
    //func urlDidLoaded(for dog: DogView)
}

struct Dogs : Codable {
    let message : Dictionary<String, [String]>
    let status: String
    
    init() {
        message = [:]
        status = ""
    }
}

struct ImageURL : Codable {
    let message : String
    let status : String
}

class DogView {
    let uid = UUID().uuidString
    
    let breed: String
    let subBreed : String
    var isDisplayed : Bool
    var delegate : DogViewDelegate?
    var cancel: Cancellation?
    var iconUrl: String?
    
    private(set) var icon: UIImage? {
        didSet {
            delegate?.iconDidLoaded(for: self)
        }
    }

    init(dog: ServerDog, networkHelper: NetworkHelper) {
        breed = dog.breed
        subBreed = dog.subBreed
        isDisplayed = true
    }
}

extension DogView: Equatable {
    static func == (lhs: DogView, rhs: DogView) -> Bool {
        lhs.uid == rhs.uid
    }
}

extension DogView {
    func loadImageIfNeeded(with helper: NetworkHelper) {
        if (iconUrl == nil) {
            return
        }
        if icon != nil || cancel != nil { return }
        guard let resource = ResourceFactory().createImageResource(for: iconUrl!) else { return }
        
        cancel = helper.load(resource: resource, completion: { [weak self]
            result in
            switch result {
            case .success(let image):
                self?.icon = image
            case .failure(let error):
                print(error)
            }
            self?.cancel = nil
        })
    }
    
    func loadImgURL(networkHelper: NetworkHelper) {
        if (iconUrl != nil) {
            return }
        guard let resource = ResourceFactory().getImgURL(breed: self.breed,subbreed: self.subBreed) else { print(-1); return }
        
        _ = networkHelper.load(resource: resource, completion: {[weak self] result in
            switch result {
            case let .success(ImageUrl):
                let url = ImageUrl.message
                self?.iconUrl = url
            case .failure(let error):
                print(error)
            }
        })
    }
    
    func cancelLoadImage() {
        cancel?.cancel()
        cancel = nil
    }
}

class ResourceFactory {
    func createResource() ->  Resource<Dogs>  {
        return Resource(url: URL(string: "https://dog.ceo/api/breeds/list/all")!, headers: nil)
    }
    
    func getImgURL(breed: String, subbreed: String) -> Resource<ImageURL>? {
        var urlString = "https://dog.ceo/api/breed/" + breed + "/"
        
        if subbreed != "" {
           urlString = urlString + subbreed + "/"
        }
        
        urlString = urlString + "images/random"
        
        guard let url = URL(string: urlString) else {
            return nil
        }
        
        return Resource(url: url, headers: nil)
    }
    
    func createImageResource(for urlString: String) -> Resource<UIImage>? {
        guard let url = URL(string: urlString) else {
            return nil
        }
        let parse: (Data) throws -> UIImage = {
            data in
            guard let image = UIImage(data: data) else {
                throw NSError(domain: "some_domain", code: 129, userInfo: [NSLocalizedDescriptionKey : NSLocalizedString("My String", comment: "My comment")])
            }
            return image
        }
        return Resource<UIImage>(url: url, method: .get, parse: parse)
    }
}

