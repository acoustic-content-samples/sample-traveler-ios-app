//
// Copyright 2020 Acoustic, L.P.
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//

import Foundation

/// Data Source for Gallery Image information
class GalleryDataSource: BasicDataSource<GalleryImageModel> {
    
    /**
    Loads and parses Gallery Image data .
     - Parameters:
        - maxCount: Maximum number of models to load. Uses default number if not set or nil.
        - completion: Completion handler with array of parsed models
        - result: Array of parsed models
     */
    func getData(maxCount: UInt? = nil, completion: @escaping (_ result: [GalleryImageModel]?)->()) {
        guard let url = URLProvider.galleryImagesURL(start: UInt(dataModel.count), pageSize: maxCount) else {
            completion(nil)
            return
        }
        
        getData(url: url, completion: completion)
    }
    
    override func decode(_ documentData: Data) -> GalleryImageModel? {
        return try? JSONDecoder().decode(GalleryImageModel.self, from: documentData)
    }
    
    override func getNextPage(completion: @escaping ([GalleryImageModel]?)->()) {
        guard canGetNextPage() else {
            completion(nil)
            return
        }
        getData(completion: completion)
    }
}
