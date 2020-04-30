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

/// View controller to show search results
class SearchResultController: UITableViewController {
    
    var dataSource = SearchDataSource()
    private var items = [SearchResultModel]()
    var textToSearch: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(handleRefresh(_:)), for: UIControl.Event.valueChanged)
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        guard let text = textToSearch else {
            refreshControl.endRefreshing()
            return
        }
        
        loadData(text: text) { [weak self] in
            self?.updateContent()
            refreshControl.endRefreshing()
        }
    }
    
    func cleanAllData() {
        dataSource.clearDataModels()
        items.removeAll()
    }
    
    func loadData(text: String, completion: (()->())?) {
        
        cleanAllData()
        
        dataSource.getData(searchText: text) { [weak self] (result) in
            DispatchQueue.main.async {
                guard let result = result else {
                    return
                }
                self?.items.append(contentsOf: result)
                completion?()
            }
        }
    }
    
    func search(_ text: String) {
        textToSearch = text
        
        loadData(text: text) { [weak self] in
            self?.updateContent()
        }
    }
    
    private func updateContent() {
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        
        // Cell configuration
        if indexPath.row < items.count {
            let model = items[indexPath.row]
            switch model {
            case .article(let articleModel):
                cell = tableView.dequeueReusableCell(withIdentifier: "ArticleCell", for: indexPath)
                (cell as? ArticleCell)?.configure(model: articleModel)
            case .gallery(let galleryModel):
                cell = tableView.dequeueReusableCell(withIdentifier: "ImageCell", for: indexPath)
                (cell as? ImageCell)?.configure(model: galleryModel)
            }
        }
        
        return cell ?? UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Logic to show Gallery Details
        if let cell = tableView.cellForRow(at: indexPath) as? ImageCell {
            guard
                let model = cell.model as? GalleryImageModel,
                let detailsController = storyboard?.instantiateViewController(withIdentifier: "GalleryDetailsViewController") as? GalleryDetailsViewController
                else {
                    return
            }
            
            detailsController.configure(model: model)
            present(detailsController, animated: true, completion: nil)
            
        }
        // Logic to show Article controller
        else if let cell = tableView.cellForRow(at: indexPath) as? ArticleCell {
            guard
                let model = cell.model,
                let detailsController = storyboard?.instantiateViewController(withIdentifier: "ArticleViewController") as? ArticleViewController
                else {
                    return
            }
            
            detailsController.configure(model: model, backTitle: "Back")
            self.navigationController?.pushViewController(detailsController, animated: true)
        }
    }
    
    // Data pagging logic
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {        
        if indexPath.row == items.count - 1,
            dataSource.canGetNextPage() {
            
            // Loads next page data and updates table view
            dataSource.getNextPage { [weak self] (_) in
                DispatchQueue.main.async {
                    guard
                        let dataSource = self?.dataSource
                        else {
                        return
                    }
                    
                    let startRow = indexPath.row + 1
                    let indexes = (startRow..<dataSource.dataModel.count).map({
                        return IndexPath(row: $0, section: 0)
                    })
                    
                    self?.tableView.beginUpdates()
                    self?.items = dataSource.dataModel
                    self?.tableView.insertRows(at: indexes, with: .fade)
                    self?.tableView.endUpdates()
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
