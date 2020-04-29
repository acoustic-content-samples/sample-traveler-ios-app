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

/// View controller for About screen
class AboutViewController: ViewControllerWithSearch {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var aboutTitleLabel: UILabel!
    @IBOutlet weak var aboutDescriptionLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private let dataSource = AboutDataSource()
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: UIControl.Event.valueChanged)
        return refreshControl
    }()
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        loadData { [weak self] in
            self?.updateContent()
            refreshControl.endRefreshing()
        }
    }
    
    func cleanAllData() {
        dataSource.dataModel.removeAll()
    }
    
    func loadData(completion: (()->())?) {
        
        cleanAllData()
        
        dataSource.getData { (_) in
            DispatchQueue.main.async {
                completion?()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Loads About screen data
        activityIndicator.startAnimating()
        loadData { [weak self] in
            self?.activityIndicator.stopAnimating()
            self?.updateContent()
        }
        
        scrollView.refreshControl = refreshControl
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    /// Content configuration
    func updateContent() {
        guard let model = dataSource.dataModel.first else {
            return
        }
        aboutTitleLabel.set(text: model.pageTitle.value, isFormatted: model.pageTitle.isFormattedText())
        aboutDescriptionLabel.set(text: model.aboutPageText.value, isFormatted: model.aboutPageText.isFormattedText())
    }
    
    
}
