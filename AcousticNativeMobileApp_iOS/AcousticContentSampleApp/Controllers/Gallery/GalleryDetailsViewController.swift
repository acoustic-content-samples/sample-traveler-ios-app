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

/// View controller for Gallery Details screen
class GalleryDetailsViewController: UIViewController {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageTitleLabel: UILabel!
    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet weak var contentDescriptionLabel: UILabel!
    @IBOutlet weak var contentImageHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /// Configures conent with GalleryImageModel
    func configure(model: GalleryImageModel) {
        view.layoutIfNeeded()
        
        imageTitleLabel.set(text: model.imageTitle.value, isFormatted: model.imageTitle.isFormattedText())
        contentDescriptionLabel.set(text: model.imageDescription.value, isFormatted: model.imageDescription.isFormattedText())
               
        // Loads image data
        if let imageURL = URLProvider.imageURL(path: model.galleryImage.url) {
            activityIndicator.startAnimating()
            BasicDataLoader.shared.loadImage(url: imageURL) { [weak self] (image) in
                DispatchQueue.main.async {
                    self?.activityIndicator.stopAnimating()
                    self?.contentImageView.contentMode = .scaleAspectFill
                    self?.contentImageView.transition(toImage: image)
                    
                    let safeImageWidth = max(1.0, (image?.size.width ?? 1.0))
                    let imageRatio = (image?.size.height ?? 1.0) / safeImageWidth
                    UIView.animate(withDuration: 0.3) {
                        guard let self = self else {
                            return
                        }
                        self.contentImageHeight.constant = self.contentImageView.bounds.width * imageRatio
                        self.contentImageView.layoutIfNeeded()
                    }
                }
            }
        }
    }
    
    @IBAction func onCloseButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
