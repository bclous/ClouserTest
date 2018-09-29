//
//  PuppyAPIUtility.swift
//  ClouserNoom
//
//  Created by Brian Clouser on 9/26/18.
//  Copyright © 2018 Brian Clouser. All rights reserved.
//

import Foundation
import Alamofire

class PuppyAPIUtility : NSObject  {
    
    public static let shared = PuppyAPIUtility()
    var currentRequest : DataRequest?
    private let baseEndpoint : String = "http://www.recipepuppy.com/api/?"
    
    public func getRecipes(searchItem: String, ingredients: [String], page: Int, maxAttempts: Int, success: @escaping (_ response: [String : Any]) -> (), failure: @escaping (_ error: Error?) -> ()) {
        
        cancelCurrentRequest()
        
        let ingredientsString = ingredients.count == 0 ? "" : "i=\(ingredients.joined(separator: ","))&"
        let adjustedSearchItem = searchItem.replacingOccurrences(of: " ", with: "+")
        let queryString = "q=\(adjustedSearchItem)&"
        let pageString = "p=\(page)"
        let urlString = "\(baseEndpoint)\(ingredientsString)\(queryString)\(pageString)"
        let dataRequest = Alamofire.request(urlString)
        currentRequest = dataRequest
        
        getRecipesWithRequest(dataRequest: dataRequest, attempt: 1, maxAttempts: maxAttempts, success: { (response) in
            success(response)
            self.currentRequest = nil
        }) { (error) in
            failure(error)
            self.currentRequest = nil
        }
    }
    
    private func getRecipesWithRequest(dataRequest: DataRequest, attempt: Int, maxAttempts: Int, success: @escaping (_ response: [String : Any]) -> (), failure: @escaping (_ error: Error?) -> ()) {
        
        let validAttempt = attempt < 1 ? 1 : attempt
        let delay : Double = validAttempt == 1 ? 0 : 1.0 * (pow(2, validAttempt - 2) as NSDecimalNumber).doubleValue
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            if self.isRequestCurrentRequest(request: dataRequest) {
                dataRequest.responseJSON(completionHandler: { (response) in
                    if (response.result.isFailure) {
                        if (attempt >= maxAttempts) {
                            failure(response.error)
                        } else {
                            self.getRecipesWithRequest(dataRequest: dataRequest, attempt: attempt + 1, maxAttempts: maxAttempts, success: success, failure: failure)
                        }
                    } else {
                        if let result = response.value as? [String : Any] {
                            success(result)
                        } else {
                            failure(response.error)
                        }
                    }
                })
            }
        }
    }
    
    public func cancelCurrentRequest() {
        if let currentRequest = currentRequest {
            currentRequest.cancel()
        }
    }
    
    private func isRequestCurrentRequest(request: DataRequest) -> Bool {
        if let currentRequestURLString = currentRequest?.request?.url?.absoluteString, let requestString = request.request?.url?.absoluteString {
            return currentRequestURLString == requestString
        } else {
            return false
        }
    }
    
}
