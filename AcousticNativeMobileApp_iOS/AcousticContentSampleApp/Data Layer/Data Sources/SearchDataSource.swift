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

/// Data Source for Search Results
class SearchDataSource: BasicDataSource<SearchResultModel> {
    var searchText: String?
    
    override func clearDataModels() {
        super.clearDataModels()
        searchText = nil
    }
    
    /**
       Loads and parses Search Results for giver `searchText`.
        - Parameters:
           - searchText: Text to search.
           - completion: Completion handler with array of parsed models
           - result: Array of parsed models
        */
    func getData(searchText: String, completion: @escaping (_ result: [SearchResultModel]?)->()) {
        guard let url = URLProvider.searchURL(start: UInt(dataModel.count), text: searchText) else {
            completion(nil)
            return
        }
        
        self.searchText = searchText
        
        getData(url: url, completion: completion)
    }
    
    override func decode(_ documentData: Data) -> SearchResultModel? {
        if let model = try? JSONDecoder().decode(GalleryImageModel.self, from: documentData) {
            return .gallery(model)
        } else if let model = try? JSONDecoder().decode(TravelArticleModel.self, from: documentData) {
            return .article(model)
        } else {
            return nil
        }
    }
    
    override func getNextPage(completion: @escaping ([SearchResultModel]?)->()) {
        guard
            canGetNextPage(),
            let searchText = searchText
            else {
                completion(nil)
                return
        }
        getData(searchText: searchText, completion: completion)
    }
}
