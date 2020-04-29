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

/// View controller for Destinations screen
class DestinationsViewController: ViewControllerWithSearch {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var selectedItemIndex = 0
    private let destinationsDataSource = DestinationsDataSource()
    private var regions = [RegionModel]()
    private var countries = [CountryModel]()
    private let dispatchGroup = DispatchGroup()
    
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
        // Clear all cached country data
        CountryDataSource.shared.clearDataModels()
        
        destinationsDataSource.dataModel.removeAll()
        regions.removeAll()
        countries.removeAll()
    }
    
    func loadData(completion: (()->())?) {
        cleanAllData()
        
        // Loads Destinations data
        dispatchGroup.enter()
        destinationsDataSource.getData { [weak self] (model) in
            guard
                let this = self,
                let model = model?.first
                else {
                    // Leave dispaatchGroup for destinationsDataSource task
                    self?.dispatchGroup.leave()
                    return
            }
            
            // Loads Regions data
            self?.regions.removeAll()
            model.regionList.categories.forEach { (category) in
                // Enter dispatchGroup for regionDataSource
                this.dispatchGroup.enter()
                RegionDataSource.shared.getData(category: category) { [weak self] (region) in
                    self?.regions.append(contentsOf: region ?? [])
                    // Leave dispaatchGroup for regionDataSource
                    self?.dispatchGroup.leave()
                }
            }
            
            // Leave dispaatchGroup for destinationsDataSource task
            this.dispatchGroup.leave()
        }
        
        // Will be called when last task leave dispatchGroup
        dispatchGroup.notify(queue: .main) {
            completion?()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }
        
        // Loads About screen data
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
        guard let categories = destinationsDataSource.dataModel.first?.regionList.categories else {
            return
        }
        
        regions.sort { (first, second) -> Bool in
            (categories.firstIndex(of: first.regionCategory ?? "") ?? 0) < (categories.firstIndex(of: second.regionCategory ?? "") ?? 0)
        }
        collectionView.reloadData()
        updateTable(with: selectedItemIndex)
    }
    
    /// Updates Counties table wit selected region index
    private func updateTable(with index: Int) {
        guard
            index < regions.count,
            let selectedCategory = regions[index].regionCategory
            else {
                return
        }
        
        // Loads County data for selected region
        CountryDataSource.shared.getData(category: selectedCategory) { [weak self] (countries) in
            DispatchQueue.main.async {
                self?.countries.removeAll()
                self?.countries.append(contentsOf: countries ?? [])
                self?.tableView.reloadData()
            }
        }
    }
}


// Region List logic
extension DestinationsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return regions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DestinationsTitleCellId", for: indexPath)
        
        // Cell configuration
        if
            let cell = cell as? SelectableTitleCell,
            indexPath.row < regions.count {
            let region = regions[indexPath.row]
            cell.configure(region: region, isActive: indexPath.row == selectedItemIndex)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.row != selectedItemIndex else {
            return
        }
        
        if let oldCell = collectionView.cellForItem(at: IndexPath(row: selectedItemIndex, section: 0)) as? SelectableTitleCell {
            oldCell.isActive = false
        }
        
        selectedItemIndex = indexPath.row
        
        if let newCell = collectionView.cellForItem(at: indexPath) as? SelectableTitleCell {
            newCell.isActive = true
        }
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        
        updateTable(with: selectedItemIndex)
    }
}


// Counties list logic
extension DestinationsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DestinationsCellId", for: indexPath)
        
        // Cell configuration
        if
            let cell = cell as? ImageCell,
            indexPath.row < countries.count {
            let country = countries[indexPath.row]
            cell.configure(model: country)
        }
        
        return cell
    }
    
    // Shows Destinations Details controller
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard
            let cell = tableView.cellForRow(at: indexPath) as? ImageCell,
            let model = cell.model as? CountryModel,
            let detailsController = storyboard?.instantiateViewController(withIdentifier: "DestinationsDetailsViewController") as? DestinationsDetailsViewController else {
            return
        }
        
        detailsController.configure(model: model)
        self.navigationController?.pushViewController(detailsController, animated: true)
    }
}
