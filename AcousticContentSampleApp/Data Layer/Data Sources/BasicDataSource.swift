//
// Copyright 2020 Acoustic, L.P.
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//

import Foundation

/// Contains basic method for data loading and parsing
class BasicDataSource<Model: Equatable> {
    
    var dataModel = [Model]()
    var deliverySearchModel: DeliverySearchModel?
        
    /**
    Loads and parses Delivery Search data for given `url`.
     - Parameters:
        - url: Delivery Search URL.
        - completion: Completion handler with array of parsed models
        - result: Array of parsed models
     */
    func getData(url: URL, completion: @escaping (_ result: [Model]?)->()) {
        BasicDataLoader.shared.loadDeliverySearch(url: url) { [weak self] (model) in
            self?.deliverySearchModel = model
            var result = [Model]()
            model?.documents?.forEach({
                guard let documentData = $0.document.data(using: .utf8) else {
                    completion(nil)
                    return
                }
                
                if let object = self?.decode(documentData) {
                    result.append(object)
                }
            })
            
            result.forEach {
                if self?.dataModel.contains($0) == false {
                    self?.dataModel.append($0)
                }
            }
            completion(result)
        }
    }
    
    /**
    Parses model object from given data.
     - Parameters:
        - documentData: Document data to parse
     - Returns: Parsed model or nil
     */
    func decode(_ documentData: Data) -> Model? {
        assertionFailure("Method decode(_ documentData: Data) have to be overrided in child class.")
        return nil
    }
    
    /**
    Remove all data models.
     */
    func clearDataModels() {
        dataModel.removeAll()
    }
    
    /**
    Loads next data page.     
     - Parameters:
        - completion: Completion handler with array of parsed models
        - result: Array of parsed models
     */
    func getNextPage(completion: @escaping (_ result: [Model]?)->()) {
        // Do nothing in basic class. Should be overrided if needed
        completion(nil)
    }
    
    /**
     Shows if all data pages were loaded.
     - Returns: Returns `true` if not all pages were loaded or `false` in other case.
     */
    func canGetNextPage() -> Bool {
        if
            let searchModel = deliverySearchModel,
            dataModel.count < searchModel.numFound {
            return true
        }
        return false
    }
}
