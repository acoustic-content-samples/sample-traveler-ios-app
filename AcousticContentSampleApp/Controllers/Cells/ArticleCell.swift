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

/// Cell to show article data
class ArticleCell: UITableViewCell {
    
    @IBOutlet weak var articleImageView: UIImageView!
    @IBOutlet weak var articleTitleLabel: UILabel!
    @IBOutlet weak var articleCountryLabel: UILabel!
    @IBOutlet weak var articleAuthorLabel: UILabel!
    
    private var imageURL: URL?
    var model: TravelArticleModel?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Cancels image loading if needed
        if let imageURL = imageURL {
            BasicDataLoader.shared.cancelTaskWithUrlIfNeeded(imageURL)
        }
        
        // Clears cell content
        model = nil
        articleTitleLabel.text = ""
        articleCountryLabel.text = ""
        articleAuthorLabel.text = ""
    }
    
    func setImagePlaceholder() {
        articleImageView.image = UIImage(systemName: "photo")
        articleImageView.contentMode = .scaleAspectFit
    }
    
    /// Cell configuration
    func configure(model: TravelArticleModel) {
        self.model = model
        
        articleTitleLabel.set(text: model.travelArticleTitle.value, isFormatted: model.travelArticleTitle.isFormattedText())
        
        // Loads County data for article
        if let category = model.countryOfTravelArticle.categories.first {
            CountryDataSource.shared.getData(category: category) { [weak self] (countries) in
                DispatchQueue.main.async {
                    guard let country = countries?.first else {
                        return
                    }
                    
                    self?.articleCountryLabel.set(text: country.countryTitle.value, isFormatted: country.countryTitle.isFormattedText())
                }
            }
        }
        
        articleAuthorLabel.text = "By \(model.articleAuthor.value)   \(model.lastModified.iso8601?.article ?? "")"
        
        guard let imageURL = URLProvider.imageURL(path: model.travelArticleImage.renditions.card.url) else {
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
        BasicDataLoader.shared.loadImage(url: imageURL) { [weak self] (image) in
            DispatchQueue.main.async {
                self?.articleImageView.contentMode = .scaleAspectFill
                self?.articleImageView.transition(toImage: image, duration: isCachedImage ? 0.0 : 0.3)
            }
        }
    }
}
