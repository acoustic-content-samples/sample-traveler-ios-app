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

/// Data Source for Region information
class RegionDataSource: BasicDataSource<RegionModel> {
    static let shared = RegionDataSource()
    
    /**
    Loads and parses Region data for given `category` or return strored data if they exist.     
     - Parameters:
        - category: Region category.
        - completion: Completion handler with array of parsed models
        - result: Array of parsed models
     */
    func getData(category: String, completion: @escaping (_ result: [RegionModel]?)->()) {
        let regions = dataModel.filter({ $0.countryList.categories.contains { $0.contains(category) }})
        guard regions.count == 0 else {
            completion(regions)
            return
        }
        
        loadData(category: category, completion: completion)
    }
    
    private func loadData(category: String, completion: @escaping ([RegionModel]?)->()) {
        guard let url = URLProvider.regionURL(category: category) else {
            completion(nil)
            return
        }
        
        getData(url: url, completion: completion)
    }
    
    override func decode(_ documentData: Data) -> RegionModel? {
        return try? JSONDecoder().decode(RegionModel.self, from: documentData)
    }
}
