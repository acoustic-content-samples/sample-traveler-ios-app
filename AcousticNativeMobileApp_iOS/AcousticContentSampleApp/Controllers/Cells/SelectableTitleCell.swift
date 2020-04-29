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

/// Cell to show Region name
class SelectableTitleCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var selectedLineView: UIView!
    
    private var model: RegionModel?
    private var isActive_internal = false
    public var isActive: Bool {
        get {
            return isActive_internal
        }
        set {
            isActive_internal = newValue
            titleLabel.textColor = newValue ? selectedLineView.backgroundColor : .black
            titleLabel.font = UIFont.systemFont(ofSize: 15, weight: newValue ? .bold : .regular)
            selectedLineView.isHidden = !newValue
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Clears cell content
        model = nil
        isActive = false
    }
    
    /// Cell configuration
    func configure(region: RegionModel, isActive: Bool) {
        model = region
        self.isActive = isActive
        titleLabel.set(text: region.regionTitle.value, isFormatted: region.regionTitle.isFormattedText())
    }
}
