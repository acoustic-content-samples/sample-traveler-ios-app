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

/// Cell to show image data
class ImageCell: UITableViewCell {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet weak var contentImageTitle: UILabel!
    
    private var imageURL: URL?
    var model: Any?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Cancels image loading if needed
        if let imageURL = imageURL {
            BasicDataLoader.shared.cancelTaskWithUrlIfNeeded(imageURL)
        }
        
        // Clears cell content
        model = nil
    }
    
    func setImagePlaceholder() {
        contentImageView.image = UIImage(systemName: "photo")
        contentImageView.contentMode = .scaleAspectFit
    }
    
    /// Cell configuration with GalleryImageModel
    func configure(model: GalleryImageModel) {        
        self.model = model
        
        guard let imageURL = URLProvider.imageURL(path: model.galleryImage.renditions.rectangleCard.url) else {
            setImagePlaceholder()
            contentImageTitle.text = ""
            return
        }
        self.imageURL = imageURL
        
        // Shows image placeholder if we don't have cached image
        let isCachedImage = BasicDataLoader.shared.isCachedImage(with: imageURL)
        if !isCachedImage {
            setImagePlaceholder()
            contentImageTitle.text = ""
        }
        
        // Loads Image data
        activityIndicator.startAnimating()
        BasicDataLoader.shared.loadImage(url: imageURL) { [weak self] (image) in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                
                self?.contentImageTitle.set(text: model.imageTitle.value, isFormatted: model.imageTitle.isFormattedText())
                
                self?.contentImageView.contentMode = .scaleAspectFill
                self?.contentImageView.transition(toImage: image, duration: isCachedImage ? 0.0 : 0.3)
            }
        }
    }
    
    // Cell configuration with CountryModel
    func configure(model: CountryModel) {
        self.model = model
        
        guard let imageURL = URLProvider.imageURL(path: model.countryImage.renditions.default.url) else {
            setImagePlaceholder()
            contentImageTitle.text = ""
            return
        }
        self.imageURL = imageURL
        
        // Shows image placeholder if we don't have cached image
        let isCachedImage = BasicDataLoader.shared.isCachedImage(with: imageURL)
        if !isCachedImage {
            setImagePlaceholder()
            contentImageTitle.text = ""
        }
        
        // Loads Image data
        activityIndicator.startAnimating()
        BasicDataLoader.shared.loadImage(url: imageURL) { [weak self] (image) in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                
                self?.contentImageTitle.set(text: model.countryTitle.value, isFormatted: model.countryTitle.isFormattedText())
                
                self?.contentImageView.contentMode = .scaleAspectFill
                self?.contentImageView.transition(toImage: image)
            }
        }
    }
}
