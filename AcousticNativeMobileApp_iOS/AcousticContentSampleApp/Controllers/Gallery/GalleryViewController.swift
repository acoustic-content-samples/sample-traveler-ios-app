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

/// View controller for Gallery screen
class GalleryViewController: ViewControllerWithSearch {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
    private let dataSource = GalleryDataSource()
    fileprivate var items = [GalleryImageModel]()
    
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
        items.removeAll()
    }
    
    func loadData(completion: (()->())?) {
        
        cleanAllData()
        
        dataSource.getData { [weak self] (result) in
            DispatchQueue.main.async {
                guard let result = result else {
                    completion?()
                    return
                }
                
                self?.items.append(contentsOf: result)
                completion?()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Loads Gallery data
        activityIndicator.startAnimating()
        loadData { [weak self] in
            self?.activityIndicator.stopAnimating()
            self?.updateContent()
        }
        
        tableView.addSubview(refreshControl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func updateContent() {
        tableView.reloadData()
    }
}


extension GalleryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GalleryCellId", for: indexPath)
        
        // Cell configuration
        if
            let cell = cell as? ImageCell,
            indexPath.row < items.count {
            let model = items[indexPath.row]
            cell.configure(model: model)
        }
        
        return cell
    }
    
    // Shows Gallery Details screen
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard
            let cell = tableView.cellForRow(at: indexPath) as? ImageCell,
            let model = cell.model as? GalleryImageModel,
            let detailsController = storyboard?.instantiateViewController(withIdentifier: "GalleryDetailsViewController") as? GalleryDetailsViewController
            else {
                return
        }
        
        detailsController.configure(model: model)
        present(detailsController, animated: true, completion: nil)
    }
    
    // Data pagging logic
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == items.count - 1,
            dataSource.canGetNextPage() {
            
            // Loads next page data and updates table view
            dataSource.getNextPage { [weak self] (model) in
                DispatchQueue.main.async {
                    guard let model = model else {
                        return
                    }
                    
                    let startRow = indexPath.row + 1
                    let indexes = (startRow..<startRow + model.count).map({
                        return IndexPath(row: $0, section: 0)
                    })
                    
                    self?.tableView.beginUpdates()
                    self?.items.append(contentsOf: model)
                    self?.tableView.insertRows(at: indexes, with: .fade)
                    self?.tableView.endUpdates()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }
}
