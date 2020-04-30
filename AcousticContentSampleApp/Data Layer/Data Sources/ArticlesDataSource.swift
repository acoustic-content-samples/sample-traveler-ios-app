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

/// Data Source for Travel Article information
class ArticlesDataSource: BasicDataSource<TravelArticleModel> {
    
    /**
    Loads and parses Travel Articles.
     - Parameters:
        - category: Filters Travel Article by category if set.
        - maxCount: Maximum number of models to load. Uses default number if not set or nil.
        - completion: Completion handler with array of parsed models
        - result: Array of parsed models
     */
    func getData(category: String? = nil, maxCount: UInt? = nil, completion: @escaping (_ result: [TravelArticleModel]?)->()) {
        guard let url = URLProvider.travelArticleURL(start: UInt(dataModel.count), pageSize: maxCount, category: category) else {
            completion(nil)
            return
        }

        getData(url: url, completion: completion)
    }
    
    override func decode(_ documentData: Data) -> TravelArticleModel? {
        try? JSONDecoder().decode(TravelArticleModel.self, from: documentData)
    }
    
    override func getNextPage(completion: @escaping ([TravelArticleModel]?)->()) {
        guard canGetNextPage() else {
            completion(nil)
            return
        }
        getData(completion: completion)
    }
}
