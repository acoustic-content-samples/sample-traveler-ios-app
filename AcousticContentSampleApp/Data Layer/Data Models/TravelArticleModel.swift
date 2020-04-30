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

/// Model for Travel Article data
struct TravelArticleModel: Decodable, EquatableModel {
    
    enum CodingKeys: String, CodingKey {
        case id
        case lastModified
        case elements
        case travelArticleTitle
        case travelArticleImage
        case articleAuthor
        case travelArticleText
        case countryOfTravelArticle
    }
    
    struct ArticleContentImageModel: CodableContentImage {
        struct RenditionsModel: Codable {
            let card: ContentRenditionModel
            let `default`: ContentRenditionModel
        }
        
        let renditions: RenditionsModel
        var elementType: String
        var url: String
    }
    
    var id: String
    let lastModified: String
    let travelArticleTitle: ContentTextModel
    let travelArticleImage: ArticleContentImageModel
    let articleAuthor: ContentTextModel
    let travelArticleText: ContentTextModel
    let countryOfTravelArticle: ContentCategoryModel
    
    init(from decoder: Decoder) throws {
        let root = try decoder.container(keyedBy: CodingKeys.self)
        lastModified = try root.decode(String.self, forKey: .lastModified)
        id = try root.decode(String.self, forKey: .id)
        
        let elements = try root.nestedContainer(keyedBy: CodingKeys.self, forKey: .elements)
        travelArticleTitle = try elements.decode(ContentTextModel.self, forKey: .travelArticleTitle)
        travelArticleImage = try elements.decode(ArticleContentImageModel.self, forKey: .travelArticleImage)
        articleAuthor = try elements.decode(ContentTextModel.self, forKey: .articleAuthor)
        travelArticleText = try elements.decode(ContentTextModel.self, forKey: .travelArticleText)
        countryOfTravelArticle = try elements.decode(ContentCategoryModel.self, forKey: .countryOfTravelArticle)
    }
}
