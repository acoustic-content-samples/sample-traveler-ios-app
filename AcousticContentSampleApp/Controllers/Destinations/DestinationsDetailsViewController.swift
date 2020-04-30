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

/// View controller for Destinations Details screen
class DestinationsDetailsViewController: ViewControllerWithSearch {
        
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    private let dataSource = ArticlesDataSource()
    private var country: CountryModel?
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: UIControl.Event.valueChanged)
        return refreshControl
    }()
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        guard let country = country else {
            refreshControl.endRefreshing()
            return
        }
        
        loadData(country: country) { [weak self] in
            self?.updateContent()
            refreshControl.endRefreshing()
        }
    }
    
    func cleanAllData() {
        dataSource.dataModel.removeAll()
    }
    
    func loadData(country: CountryModel, completion: (()->())?) {
        
        guard let category = country.countryValueForPage.categories.first else {
            completion?()
            return
        }
        
        cleanAllData()
        
        dataSource.getData(category: category) { _ in 
            DispatchQueue.main.async {
                completion?()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.addSubview(refreshControl)
    }
    
    @IBAction func onBackButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    /// Configures content with CountryModel
    func configure(model: CountryModel) {
        view.layoutIfNeeded()
        
        country = model
        titleLabel.set(text: model.countryTitle.value, isFormatted: model.countryTitle.isFormattedText())
        
        // Loads articles for given category
        loadData(country: model) { [weak self] in
            self?.updateContent()
        }
    }
    
    private func updateContent() {
        tableView.reloadData()
    }
}


extension DestinationsDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.dataModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleCellId", for: indexPath)
        
        // Cell configuration
        if
            let cell = cell as? ArticleCell,
            indexPath.row < dataSource.dataModel.count {
            let model = dataSource.dataModel[indexPath.row]
            cell.configure(model: model)
        }
        
        return cell
    }
    
    // Shows Article details screen
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard
            let country = country,
            let cell = tableView.cellForRow(at: indexPath) as? ArticleCell,
            let model = cell.model,
            let articleController = storyboard?.instantiateViewController(withIdentifier: "ArticleViewController") as? ArticleViewController
            else {
            return
        }
        
        articleController.configure(model: model, backTitle: country.countryTitle.value)
        self.navigationController?.pushViewController(articleController, animated: true)
    }
}
