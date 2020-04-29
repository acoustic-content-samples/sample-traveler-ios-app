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

/// Basic view controller that contains search logic
class ViewControllerWithSearch: UIViewController, UISearchBarDelegate {
    @IBOutlet weak var searchBar: UISearchBar?
    var searchController: SearchResultController?
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        removeSearchController()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard
            let text = searchBar.text,
            text.count > 0
            else {
                return
        }
        
        if
            searchController == nil,
            let searchController = storyboard?.instantiateViewController(withIdentifier: "SearchResultController") as? SearchResultController {
            
            self.searchController = searchController
            addChild(searchController)
            searchController.view.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(searchController.view)
            searchController.view.topAnchor.constraint(equalTo: searchBar.bottomAnchor).isActive = true
            searchController.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            searchController.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            searchController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
            
            searchController.view.alpha = 0
            UIView.animate(withDuration: 0.2) {
                searchController.view.alpha = 1.0
            }
        }
        
        self.searchController?.search(text)
        view.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Do nothing
    }
    
    func removeSearchController() {
        searchBar?.showsCancelButton = false
        searchBar?.text = nil
        searchController?.view.removeFromSuperview()
        searchController?.removeFromParent()
        searchController = nil
        view.endEditing(true)
    }
}
