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
import WebKit

/// View controller to show Article content
class ArticleViewController: UIViewController {
    
    @IBOutlet weak var webViewHeight: NSLayoutConstraint!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var webActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var backTitleButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet weak var contentImageHeight: NSLayoutConstraint!
    
    @IBAction func onBackButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    /// Configures content with model and back button title
    func configure(model: TravelArticleModel, backTitle: String) {
        view.layoutIfNeeded()
        
        backTitleButton.setTitle(backTitle, for: .normal)
        
        titleLabel.set(text: model.travelArticleTitle.value, isFormatted: model.travelArticleTitle.isFormattedText())
        subtitleLabel.text = "By \(model.articleAuthor.value)   \(model.lastModified.iso8601?.article ?? "")"
        
        // Configures web view to article content
        webView.navigationDelegate = self
        webView.isUserInteractionEnabled = false
        let modifiedFont = String(format:"<span style=\"font-size: \(30)\">%@</span>", model.travelArticleText.value)
        webActivityIndicator.startAnimating()
        webView.loadHTMLString(modifiedFont, baseURL: URL(string: URLProvider.domainName))
                    
        // Loads image data
        if let imageURL = URLProvider.imageURL(path: model.travelArticleImage.url) {
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
}

extension ArticleViewController: WKNavigationDelegate {
    
    /// Sets correct scroll height
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.webView.evaluateJavaScript("document.readyState", completionHandler: { [weak self] (complete, error) in
            if complete != nil {
                self?.webView.evaluateJavaScript("document.body.scrollHeight", completionHandler: { (height, error) in
                    self?.webViewHeight.constant = webView.scrollView.contentSize.height
                    self?.view.layoutIfNeeded()
                    self?.webActivityIndicator.stopAnimating()
                })
            }
        })
    }
}
