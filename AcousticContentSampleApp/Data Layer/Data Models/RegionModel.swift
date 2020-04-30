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

/// Model for Region data
struct RegionModel: Decodable, EquatableModel {
    
    enum CodingKeys: String, CodingKey {
        case id
        case elements
        case regionTitle
        case countryList
    }
    
    var id: String
    let regionTitle: ContentTextModel
    let countryList: ContentCategoryModel
    
    init(from decoder: Decoder) throws {
        let root = try decoder.container(keyedBy: CodingKeys.self)
        id = try root.decode(String.self, forKey: .id)
        let elements = try root.nestedContainer(keyedBy: CodingKeys.self, forKey: .elements)
        regionTitle = try elements.decode(ContentTextModel.self, forKey: .regionTitle)
        countryList = try elements.decode(ContentCategoryModel.self, forKey: .countryList)
    }
    
    var regionCategory: String? {
        guard
            let category = countryList.categories.first,
            let countryIndex = category.lastIndex(of: "/")
            else {
                return nil
        }
        return String(category.prefix(upTo: countryIndex))
    }
}
