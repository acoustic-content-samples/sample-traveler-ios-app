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

/// Model for Home screen data
struct HomeModel: Decodable, EquatableModel {
    
    enum CodingKeys: String, CodingKey {
        case id
        case elements
        case websiteTitle
        case imageSliderSettings
        case articlePreviewsSettings
    }
    
    struct SettingsModel: Codable {
        
        struct ValueModel: Codable {
            
            struct ContentNumberModel: Codable {
                let elementType: String
                let value: Int
            }
            
            private enum CodingKeys: String, CodingKey {
                case numberOfListItems
                case displayTime = "DisplayTime"
            }
            
            let numberOfListItems: ContentNumberModel
            let displayTime: ContentNumberModel?
        }
        
        let elementType: String
        let value: ValueModel
    }
    
    var id: String
    let websiteTitle: ContentTextModel
    let imageSliderSettings: SettingsModel
    let articlePreviewsSettings: SettingsModel
    
    init(from decoder: Decoder) throws {
        let root = try decoder.container(keyedBy: CodingKeys.self)
        id = try root.decode(String.self, forKey: .id)
        let elements = try root.nestedContainer(keyedBy: CodingKeys.self, forKey: .elements)
        websiteTitle = try elements.decode(ContentTextModel.self, forKey: .websiteTitle)
        imageSliderSettings = try elements.decode(SettingsModel.self, forKey: .imageSliderSettings)
        articlePreviewsSettings = try elements.decode(SettingsModel.self, forKey: .articlePreviewsSettings)
    }
}
