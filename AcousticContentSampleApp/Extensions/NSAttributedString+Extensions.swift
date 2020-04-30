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

extension NSAttributedString {
    
    /**
    Creates attributed string with html formating.
     - Parameters:
        - htmlText: Text to show.
        - fontSize: If `true` then text will be formatted based on html tags. In other case will use plain text.
     - Returns: Attributed string or nil.
    */
    static func htmlText(_ htmlText: String, fontSize: CGFloat) -> NSAttributedString? {
        let modifiedFont = String(format:"<span style=\"font-family: '-apple-system', 'HelveticaNeue'; font-size: \(fontSize)\">%@</span>", htmlText)
        
        guard let data = modifiedFont.data(using: .unicode, allowLossyConversion: true) else {
            return nil
        }
        
        let attrStr = try? NSAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue],
            documentAttributes: nil)
        return attrStr
    }
}
