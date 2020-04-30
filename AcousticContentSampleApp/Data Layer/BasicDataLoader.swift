//
// Copyright 2020 Acoustic, L.P.
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//

import UIKit

/// Contains basic method for data loading
class BasicDataLoader {
    static let shared = BasicDataLoader()
    
    private let cacheMemoryCapacity = 60 * 1024 * 1024 // 60MB
    private let cacheDiskCapacity = 60 * 1024 * 1024 // 60MB
    
    private let session: URLSession
    
    init() {
        let config = URLSessionConfiguration.default
        config.urlCache = URLCache(memoryCapacity: cacheMemoryCapacity, diskCapacity: cacheDiskCapacity)
        session = URLSession(configuration: config)
    }
    
    /**
    Cancels active `URLSession` data task with given url.
    - Parameter url: URL of task to cancel.
    */
    func cancelTaskWithUrlIfNeeded(_ url: URL) {
      session.getAllTasks { tasks in
        tasks
          .filter { $0.originalRequest?.url == url }.first?
          .cancel()
      }
    }

    /**
    Basic load method.
     - Parameters:
        - url: URL to load.
        - completion: Data task completion handler. Called when task is finished.
        - data: Date loaded by request or nil
        - response: Request response or nil
        - error: Any request error or nil
     */
    func load(from url: URL, completion: @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> ()) {
        session.dataTask(with: url, completionHandler: completion).resume()
    }
    
    /**
    Loads Delivery Search request data.
     - Parameters:
        - url: Delivery Search URL.
        - completion: Delivery Search request completion handler. Called when task is finished.
        - model: DeliverySearchModel or nil
     */
    func loadDeliverySearch(url: URL, completion: @escaping (_ model: DeliverySearchModel?) -> ()) {
        load(from: url) { (data, response, error) in
            guard
                (response as? HTTPURLResponse)?.statusCode == 200,
                let data = data,
                error == nil
                else {
                    completion(nil)
                    return
            }
            
            let searchModel = try? JSONDecoder().decode(DeliverySearchModel.self, from: data)
            completion(searchModel)
        }
    }
    
    /**
    Loads `UIImage` with given `url`.     
     - Parameters:
        - url: Image URL.
        - completion: Image loading request completion handler. Called when task is finished.
        - image: Image or nil
     */
    func loadImage(url: URL, completion: @escaping (_ image: UIImage?) -> ()) {
        load(from: url) { (data, response, error) in
            guard
                (response as? HTTPURLResponse)?.statusCode == 200,
                let data = data,
                error == nil,
                let image = UIImage(data: data)
                else {
                    completion(nil)
                    return
            }
            
            completion(image)
        }
    }
    
    /**
    Checks if image with given `url` is already cached
     - Parameters:
        - url: Image url.
     - Returns: Returns `true` is image already cached or `false` in other case.
     */
    func isCachedImage(with url: URL) -> Bool {        
        return session.configuration.urlCache?.cachedResponse(for: URLRequest(url: url)) != nil
    }
}
