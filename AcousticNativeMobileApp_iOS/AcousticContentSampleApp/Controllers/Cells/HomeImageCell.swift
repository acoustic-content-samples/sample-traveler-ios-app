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

/// Cell to show Image on Home screen scroll
class HomeImageCell: UICollectionViewCell {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    private var imageURL: URL?
    var titleModel: ContentTextModel?
    var contentModel: GalleryImageModel?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Cancels image loading if needed
        if let imageURL = imageURL {
            BasicDataLoader.shared.cancelTaskWithUrlIfNeeded(imageURL)
        }
        
        // Clears cell content
        titleModel = nil
        contentModel = nil
        titleLabel.text = ""
        subTitleLabel.text = ""
    }
    
    func setImagePlaceholder() {
        backgroundImageView.image = UIImage(systemName: "photo")
        backgroundImageView.contentMode = .scaleAspectFit
    }
    
    /// Cell configation
    func configure(titleModel: ContentTextModel?, contentModel: GalleryImageModel) {
        self.titleModel = titleModel
        self.contentModel = contentModel
                
        guard let imageURL = URLProvider.imageURL(path: contentModel.galleryImage.renditions.rectangleCard.url) else {
            setImagePlaceholder()
            return
        }
        self.imageURL = imageURL
        
        // Shows image placeholder if we don't have cached image
        let isCachedImage = BasicDataLoader.shared.isCachedImage(with: imageURL)
        if !isCachedImage {
            setImagePlaceholder()
        }
        
        // Loads image data
        activityIndicator.startAnimating()
        BasicDataLoader.shared.loadImage(url: imageURL) { [weak self] (image) in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                
                if let titleModel = titleModel {
                    self?.titleLabel.set(text: titleModel.value, isFormatted: titleModel.isFormattedText())
                }
                self?.subTitleLabel.set(text: contentModel.imageTitle.value, isFormatted: contentModel.imageTitle.isFormattedText())
                
                self?.backgroundImageView.contentMode = .scaleAspectFill
                self?.backgroundImageView.transition(toImage: image, duration: isCachedImage ? 0.0 : 0.3)
            }
        }
        
    }
}
