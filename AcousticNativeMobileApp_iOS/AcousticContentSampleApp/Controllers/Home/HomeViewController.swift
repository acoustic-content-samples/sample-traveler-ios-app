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

/// View controller for Home screen
class HomeViewController: ViewControllerWithSearch {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var tableView: UITableView!
    
    private let homeDataSource = HomeDataSource()
    private let galleryDataSource = GalleryDataSource()
    private let articlesDataSource = ArticlesDataSource()
    private let dispatchGroup = DispatchGroup()
    private var animationTimer: Timer?
    
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
        homeDataSource.dataModel.removeAll()
        galleryDataSource.dataModel.removeAll()
        articlesDataSource.dataModel.removeAll()
    }
    
    // Loads home data information
    func loadData(completion: (()->())?) {
        cleanAllData()
        
        dispatchGroup.enter()
        homeDataSource.getData { [weak self] (model) in
            guard
                let this = self,
                let model = model?.first
                else {
                    // Leave dispaatchGroup for homeDataSource task
                    self?.dispatchGroup.leave()
                    return
            }
            
            // Loads gallery images for top image scroll
            // Enter dispatchGroup for galleryDataSource
            this.dispatchGroup.enter()
            let sliderItemsCount = model.imageSliderSettings.value.numberOfListItems.value
            this.galleryDataSource.getData(maxCount: UInt(sliderItemsCount)) { [weak self] (galleryModel) in
                // Leave dispatchGroup for galleryDataSource
                self?.dispatchGroup.leave()
            }
            
            // Loads travel articles for home screen
            // Enter dispatchGroup for articlesDataSource
            this.dispatchGroup.enter()
            let articlesItemsCount = model.articlePreviewsSettings.value.numberOfListItems.value
            this.articlesDataSource.getData(maxCount: UInt(articlesItemsCount)) { [weak self] (articlesModel) in
                // Leave dispatchGroup for articlesDataSource
                self?.dispatchGroup.leave()
            }
            
            // Leave dispaatchGroup for homeDataSource task
            this.dispatchGroup.leave()
        }
        
        // Will be called when last task leave dispatchGroup
        dispatchGroup.notify(queue: .main) {
            completion?()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.startAnimating()
        loadData { [weak self] in
            self?.activityIndicator.stopAnimating()
            self?.updateContent()
        }
        
        tableView.addSubview(refreshControl)
    }
    
    private func updateContent() {
        pageControl.numberOfPages = galleryDataSource.dataModel.count
        collectionView.reloadData()
        tableView.reloadData()
        
        configureTimer()
    }
    
    /// Configures top image scroll auto scroll timer
    private func configureTimer() {
        guard
            pageControl.numberOfPages > 0,
            let homeModel = homeDataSource.dataModel.first,
            let duration = homeModel.imageSliderSettings.value.displayTime?.value
            else {
            return
        }
        animationTimer?.invalidate()
        animationTimer = Timer.scheduledTimer(withTimeInterval: Double(duration), repeats: true, block: { [weak self] (_) in
            UIView.animate(withDuration: 0.2) {
                guard
                    let self = self,
                    self.pageControl.numberOfPages > 0
                    else {
                        return
                }
                
                let nextPage = (self.pageControl.currentPage + 1) % self.pageControl.numberOfPages
                self.collectionView.scrollToItem(at: IndexPath(item: nextPage, section: 0), at: .centeredHorizontally, animated: true)
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        configureTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        animationTimer?.invalidate()
    }
    
    /// Handels tap on page indicator
    @IBAction func onPageControlValueChanged(_ sender: UIPageControl) {
        collectionView.scrollToItem(at: IndexPath(item: sender.currentPage, section: 0), at: .centeredHorizontally, animated: true)
    }
}

// Top image scroll logic
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return galleryDataSource.dataModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeImageCellId", for: indexPath)
        
        // Cell configuration
        if
            let cell = cell as? HomeImageCell,
            indexPath.row < galleryDataSource.dataModel.count {
            let model = galleryDataSource.dataModel[indexPath.row]
            cell.configure(titleModel: homeDataSource.dataModel.first?.websiteTitle, contentModel: model)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Shows Gallery details screen
        guard
            let cell = collectionView.cellForItem(at: indexPath) as? HomeImageCell,
            let model = cell.contentModel,
            let detailsController = storyboard?.instantiateViewController(withIdentifier: "GalleryDetailsViewController") as? GalleryDetailsViewController
            else {
                return
        }
        
        detailsController.configure(model: model)
        present(detailsController, animated: true, completion: nil)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == collectionView,
            collectionView.frame.size.width > 0 {
            pageControl.currentPage = Int(round(scrollView.contentOffset.x / collectionView.frame.size.width))
        }
    }
}

// Travel article table logic
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articlesDataSource.dataModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleCellId", for: indexPath)
        
        // Cell configuration
        if
            let cell = cell as? ArticleCell,
            indexPath.row < articlesDataSource.dataModel.count {
            let model = articlesDataSource.dataModel[indexPath.row]
            cell.configure(model: model)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Shows Article details screen
        guard
            let cell = tableView.cellForRow(at: indexPath) as? ArticleCell,
            let model = cell.model,
            let articleController = storyboard?.instantiateViewController(withIdentifier: "ArticleViewController") as? ArticleViewController
            else {
            return
        }
        
        articleController.configure(model: model, backTitle: "Home")        
        self.navigationController?.pushViewController(articleController, animated: true)
    }
}
