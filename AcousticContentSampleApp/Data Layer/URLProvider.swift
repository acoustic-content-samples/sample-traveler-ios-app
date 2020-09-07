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

/// Provides all URLs and help methods.
class URLProvider {
    
    static let contentHubId = "00000000-0000-0000-0000-00000000000"
    static let domainName = "https://your-domain-name.com"
    static let path = "api/\(contentHubId)"
    static let baseURL = "\(domainName)/\(path)"
    static let searchURL = "\(baseURL)/delivery/v1/search"
    static let rowsCount: UInt = 3
    
    /**
    Creates Delivery Serach URL with `parameters`.
    - Parameter parameters: Search parameters.
    - Returns: Delivery Serach URL or `nil`
    */
    static func searchURL(with parameters: [String: String?]) -> URL? {
        var urlComponents = URLComponents(string: searchURL)
        urlComponents?.queryItems = parameters.compactMap {
            URLQueryItem(name: $0, value: $1)
        }
        return urlComponents?.url
    }
    
    /**
    Creates URL for image based on given `path`.
    - Parameter path: Path to the image `(e.g. /1c6667c8-6883-42ae-9547-183f169548d2/dxresources/4f61/4f613ed2-9367-4dd3-acae-8d1ad021f7e9.png)`.
    - Returns: Image URL or `nil`
    */
    static func imageURL(path: String) -> URL? {
        let string = domainName + path
        return URL(string: string)
    }
    
    /**
    Creates Contacts URL.
    - Returns: Contacts URL or `nil`
    */
    static func contactsURL() -> URL? {
        let url = URLProvider.searchURL(with: [
            "q": "type:\"Contact Information\" AND classification:content",
            "fl": "document"
        ])
        return url
    }
    
    /**
     Creates Home screen content URL.
     - Returns: Home screen content URL or `nil`
     */
    static func homeURL() -> URL? {
        let url = URLProvider.searchURL(with: [
            "q": "type:\"Home Information\" AND classification:content",
            "fl": "document"
        ])
        return url
    }
    
    /**
    Creates About Us URL.
    - Returns: About Us URL or `nil`
    */
    static func aboutURL() -> URL? {
        let url = URLProvider.searchURL(with: [
            "q": "type:\"About Information\" AND classification:content",
            "fl": "document"
        ])
        return url
    }
    
    /**
     Creates Destinations screen  URL.
     - Returns: Destinations screen content URL or `nil`
     */
    static func destinationsURL() -> URL? {
        let url = URLProvider.searchURL(with: [
            "q": "type:\"Destinations\" AND classification:content",
            "fl": "document"
        ])
        return url
    }
    
    /**
     Creates sorted Gallery Images URL (mostRecent on top). The maximum number of documents to include in the query result is limited to `pageSize`.
     - Parameters:
        - start: Defines an paging offset. 0 by default.
        - pageSize: The maximum number of documents to include in the query result. `rowsCount` if not set or`nil`.
     - Returns: Gallery Images URL or `nil`
     */
    static func galleryImagesURL(start: UInt = 0, pageSize: UInt? = nil) -> URL? {
        let url = URLProvider.searchURL(with: [
            "q": "type:\"Gallery Image\" AND classification:content",
            "fl": "document",
            "start": "\(start)",
            "rows": "\(pageSize ?? rowsCount)",
            "sort": "lastModified desc"
        ])
        return url
    }
    
    /**
     Creates sorted Travel Articles URL (mostRecent on top). The maximum number of documents to include in the query result is limited to `pageSize`.
     - Parameters:
        - start: Defines an paging offset. 0 by default.
        - pageSize: The maximum number of documents to include in the query result. `rowsCount` if not set or`nil`.
        - category: Filters Travel Article by category if set.
     - Returns: Travel Articles URL or `nil`
     */
    static func travelArticleURL(start: UInt = 0, pageSize: UInt? = nil, category: String? = nil) -> URL? {
        let url = URLProvider.searchURL(with: [
            "q": "type:\"Travel Article\" AND classification:content" + (category == nil ? "" : " AND categories:\"\(category ?? "")\"") ,
            "fl": "document",
            "start": "\(start)",
            "rows": "\(pageSize ?? rowsCount)",
            "sort": "lastModified desc"
        ])
        return url
    }
    
    /**
     Creates sorted by name Country URL with given `category`.
     - Parameters:
        - category: Country category to search.
     - Returns: Country URL or `nil`
     */
    static func countryURL(category: String) -> URL? {
        let url = URLProvider.searchURL(with: [
            "q": "type:Country AND categories:\"\(category)\" AND classification:content",
            "fl": "document",
            "sort": "name asc"
        ])
        return url
    }
    
    /**
     Creates Region URL with given `category`.
     - Parameters:
        - category: Region category to search.
     - Returns: Country URL or `nil`
     */
    static func regionURL(category: String) -> URL? {
        let url = URLProvider.searchURL(with: [
            "q": "type:Region AND categories:\"\(category)\" AND classification:content",
            "fl": "document"
        ])
        return url
    }
    
    /**
     Creates Search URL with given `text`.
     - Parameters:
        - start: Defines an paging offset. 0 by default.
        - pageSize: The maximum number of documents to include in the query result. `rowsCount` if not set or`nil`.
        - text: Text to search.
     - Returns: Search URL or `nil`
     */
    static func searchURL(start: UInt = 0, pageSize: UInt? = nil, text: String) -> URL? {
        let url = URLProvider.searchURL(with: [
            "fq": text.split(separator: " ").count == 1 ? "text:*\(text)*" : "text:\"\(text)\"",
            "q": "type:\"Travel Article\" OR type:\"Gallery Image\"",
            "sort": "type asc",
            "start": "\(start)",
            "rows": "\(pageSize ?? rowsCount)",
            "fl": "document"
        ])
        return url
    }
}
